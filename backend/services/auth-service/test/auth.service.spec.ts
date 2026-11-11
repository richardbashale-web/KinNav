import { AuthService } from '../src/auth/auth.service';

describe('AuthService', () => {
  it('creates a reusable anonymous identity and refreshes its token', () => {
    const service = new AuthService();
    const first = service.createAnonymous('device-uuid-1234');
    const second = service.createAnonymous('device-uuid-1234');
    expect(first.user_id).toBe(second.user_id);
    expect(service.refresh(first.refresh_token).user_id).toBe(first.user_id);
  });
});
