/// Stub SyncService - akan diisi saat Supabase diaktifkan.
/// Polanya:
///   1. Query rows pending_sync = 1
///   2. Push ke Supabase via REST/PostgREST
///   3. Set pending_sync = 0 di lokal
///   4. Pull perubahan baru dari Supabase
class SyncService {
  Future<void> syncPending() async {
    // TODO: implement saat Supabase aktif
  }
}
