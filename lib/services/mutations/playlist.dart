import 'package:fl_query/fl_query.dart';
import 'package:fl_query_hooks/fl_query_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:spotube/hooks/use_spotify_mutation.dart';

class PlaylistMutations {
  const PlaylistMutations();

  Mutation<bool, dynamic, bool> toggleFavorite(
    WidgetRef ref,
    String playlistId, {
    List<String>? refreshQueries,
    List<String>? refreshInfiniteQueries,
  }) {
    final queryClient = useQueryClient();
    return useSpotifyMutation<bool, dynamic, bool, dynamic>(
      "toggle-playlist-like/$playlistId",
      (isLiked, spotify) async {
        if (isLiked) {
          await spotify.playlists.unfollowPlaylist(playlistId);
        } else {
          await spotify.playlists.followPlaylist(playlistId);
        }
        return !isLiked;
      },
      ref: ref,
      refreshQueries: refreshQueries,
      refreshInfiniteQueries: refreshInfiniteQueries,
      onData: (data, recoveryData) async {
        await queryClient
            .refreshInfiniteQueryAllPages("current-user-playlists");
      },
    );
  }

  Mutation<bool, dynamic, String> removeTrackOf(
    WidgetRef ref,
    String playlistId,
  ) {
    return useSpotifyMutation<bool, dynamic, String, dynamic>(
      "remove-track-from-playlist/$playlistId",
      (trackId, spotify) async {
        await spotify.playlists.removeTracks([trackId], playlistId);
        return true;
      },
      ref: ref,
      refreshQueries: ["playlist-tracks/$playlistId"],
    );
  }
}
