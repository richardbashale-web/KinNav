import {
  CanActivate,
  ExecutionContext,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import * as jwt from 'jsonwebtoken';
import type { Request } from 'express';

@Injectable()
export class JwtGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<Request & { userId?: string }>();
    const authorization = request.headers.authorization;
    if (!authorization?.startsWith('Bearer ')) {
      throw new UnauthorizedException('Jeton requis.');
    }
    if (!process.env.JWT_SECRET && process.env.NODE_ENV === 'production') {
      throw new InternalServerErrorException('JWT_SECRET is required in production.');
    }
    try {
      const claims = jwt.verify(
        authorization.slice('Bearer '.length),
        process.env.JWT_SECRET ?? 'local-development-secret-change-me',
      ) as jwt.JwtPayload;
      if (typeof claims.sub !== 'string' || claims['token_type'] !== 'access') {
        throw new UnauthorizedException('Jeton invalide.');
      }
      request.userId = claims.sub;
      return true;
    } catch (error) {
      if (error instanceof UnauthorizedException) throw error;
      throw new UnauthorizedException('Jeton invalide ou expiré.');
    }
  }
}
