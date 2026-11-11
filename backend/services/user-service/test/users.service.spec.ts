import { NotFoundException } from '@nestjs/common';
import { UsersService } from '../src/users.service';

describe('UsersService', () => {
  it('creates and removes a favorite for a user', () => {
    const service = new UsersService();
    const favorite = service.addFavorite('user-1', {
      name: 'Maison',
      lat: -4.325,
      lng: 15.322,
      type: 'home',
    });
    expect(favorite.id).toBeTruthy();
    expect(() => service.removeFavorite('user-1', favorite.id)).not.toThrow();
    expect(() => service.removeFavorite('user-1', favorite.id)).toThrow(NotFoundException);
  });
});
