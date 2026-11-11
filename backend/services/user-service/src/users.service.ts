import { Injectable, NotFoundException } from '@nestjs/common';
import { randomUUID } from 'node:crypto';

export interface Favorite {
  id: string;
  name: string;
  lat: number;
  lng: number;
  address?: string;
  type: 'home' | 'work' | 'other';
}

export interface UserProfilePatch {
  display_name?: string;
}

@Injectable()
export class UsersService {
  private readonly profiles = new Map<string, Record<string, unknown>>();
  private readonly favorites = new Map<string, Favorite[]>();
  private readonly histories = new Map<string, Record<string, unknown>[]>();

  getProfile(userId: string): Record<string, unknown> {
    return this.profiles.get(userId) ?? { id: userId, auth_type: 'anonymous', tier: 'anonymous' };
  }

  updateProfile(userId: string, patch: UserProfilePatch): Record<string, unknown> {
    const profile = { ...this.getProfile(userId), ...patch, id: userId };
    this.profiles.set(userId, profile);
    return profile;
  }

  history(userId: string, page: number, limit: number) {
    const all = this.histories.get(userId) ?? [];
    return { items: all.slice((page - 1) * limit, page * limit), page, limit, total: all.length };
  }

  addFavorite(userId: string, favorite: Omit<Favorite, 'id'>): Favorite {
    const items = this.favorites.get(userId) ?? [];
    const created = { ...favorite, id: randomUUID() };
    items.push(created);
    this.favorites.set(userId, items);
    return created;
  }

  removeFavorite(userId: string, id: string): void {
    const items = this.favorites.get(userId) ?? [];
    const remaining = items.filter((item) => item.id !== id);
    if (remaining.length === items.length) throw new NotFoundException('Favori introuvable.');
    this.favorites.set(userId, remaining);
  }
}
