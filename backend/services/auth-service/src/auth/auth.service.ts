import { ConflictException, Injectable, UnauthorizedException } from '@nestjs/common';
import * as bcrypt from 'bcryptjs';
import { randomUUID } from 'node:crypto';
import * as jwt from 'jsonwebtoken';

interface UserRecord {
  id: string;
  auth_type: 'anonymous' | 'email';
  device_uuid?: string;
  email?: string;
  display_name?: string;
  password_hash?: string;
}

@Injectable()
export class AuthService {
  private readonly usersByEmail = new Map<string, UserRecord>();
  private readonly usersByDevice = new Map<string, UserRecord>();
  private readonly secret = this.getSecret();

  private getSecret(): string {
    const secret = process.env.JWT_SECRET;
    if (secret) return secret;
    if (process.env.NODE_ENV === 'production') {
      throw new Error('JWT_SECRET is required in production.');
    }
    return 'local-development-secret-change-me';
  }

  createAnonymous(deviceUuid: string) {
    let user = this.usersByDevice.get(deviceUuid);
    if (!user) {
      user = { id: randomUUID(), auth_type: 'anonymous', device_uuid: deviceUuid };
      this.usersByDevice.set(deviceUuid, user);
    }
    return this.issue(user);
  }

  async register(email: string, password: string, displayName?: string) {
    const normalizedEmail = email.trim().toLowerCase();
    if (this.usersByEmail.has(normalizedEmail)) {
      throw new ConflictException('Cette adresse e-mail est déjà utilisée.');
    }
    const user: UserRecord = {
      id: randomUUID(),
      auth_type: 'email',
      email: normalizedEmail,
      display_name: displayName,
      password_hash: await bcrypt.hash(password, 12),
    };
    this.usersByEmail.set(normalizedEmail, user);
    return this.issue(user);
  }

  async login(email: string, password: string) {
    const user = this.usersByEmail.get(email.trim().toLowerCase());
    if (!user?.password_hash || !(await bcrypt.compare(password, user.password_hash))) {
      throw new UnauthorizedException('Adresse e-mail ou mot de passe invalide.');
    }
    return this.issue(user);
  }

  refresh(token: string) {
    try {
      const claims = jwt.verify(token, this.secret) as jwt.JwtPayload;
      if (claims['token_type'] !== 'refresh' || typeof claims['sub'] !== 'string') {
        throw new UnauthorizedException('Jeton de renouvellement invalide.');
      }
      const user = [...this.usersByEmail.values(), ...this.usersByDevice.values()]
        .find((candidate) => candidate.id === claims.sub);
      if (!user) throw new UnauthorizedException('Compte introuvable.');
      return this.issue(user);
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new UnauthorizedException('Jeton de renouvellement invalide.');
    }
  }

  private issue(user: UserRecord) {
    const token = jwt.sign(
      { sub: user.id, auth_type: user.auth_type, token_type: 'access' },
      this.secret,
      { expiresIn: process.env.JWT_EXPIRES_IN ?? '1d' } as jwt.SignOptions,
    );
    const refresh_token = jwt.sign(
      { sub: user.id, token_type: 'refresh' },
      this.secret,
      { expiresIn: '7d' },
    );
    const { password_hash: _passwordHash, ...publicUser } = user;
    return { token, refresh_token, user_id: user.id, user: publicUser };
  }
}
