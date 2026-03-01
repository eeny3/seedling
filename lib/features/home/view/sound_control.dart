import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../services/audio_service.dart';
import '../../../data/database_service.dart';
import '../../../data/sound_registry.dart';
import '../../../data/theme_registry.dart';

class SoundControl extends StatefulWidget {
  const SoundControl({super.key});

  @override
  State<SoundControl> createState() => _SoundControlState();
}

class _SoundControlState extends State<SoundControl> {
  final _audioService = GetIt.I<AmbientAudioService>();
  final _db = GetIt.I<DatabaseService>();
  bool _isPlaying = false;
  String? _selectedSound; 

  @override
  void initState() {
    super.initState();
    _isPlaying = _audioService.isPlaying; 
    if (_audioService.currentAsset != null) {
      _selectedSound = _audioService.currentAsset?.split('/').last;
    } else {
      _selectedSound = 'rain.mp3'; 
    }
  }

  void _showStorePicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) { 
        return DefaultTabController(
          length: 2,
          child: StatefulBuilder( 
            builder: (context, setModalState) {
              return SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  height: 600, 
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Greenhouse Supplies", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          if (_isPlaying)
                            TextButton(
                              onPressed: () async {
                                await _audioService.stop();
                                if (mounted) setState(() => _isPlaying = false);
                                setModalState(() {}); 
                              },
                              child: const Text("Stop Audio", style: TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                      const TabBar(
                        tabs: [
                          Tab(text: "Sounds"),
                          Tab(text: "Backgrounds"),
                        ],
                        labelColor: Colors.green,
                        indicatorColor: Colors.green,
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildSoundList(modalContext, setModalState),
                            _buildThemeList(modalContext, setModalState),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          ),
        );
      },
    );
  }

  // --- SOUNDS ---
  Widget _buildSoundList(BuildContext modalContext, StateSetter setModalState) {
    final unlockedIds = _db.unlockedSoundIds;
    final mySounds = SoundRegistry.allTracks.where((t) => unlockedIds.contains(t.id)).toList();
    final lockedSounds = SoundRegistry.allTracks.where((t) => !unlockedIds.contains(t.id)).toList();

    return ListView(
      children: [
        if (mySounds.isNotEmpty) ...[
           const Padding(
             padding: EdgeInsets.symmetric(vertical: 8.0),
             child: Text("My Collection", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
           ),
           ...mySounds.map((track) => _buildSoundOption(
              modalContext, 
              setModalState, 
              track, 
              isLocked: false
            )),
        ],
        
        if (lockedSounds.isNotEmpty) ...[
           const Divider(height: 30),
           const Padding(
             padding: EdgeInsets.symmetric(vertical: 8.0),
             child: Text("Sound Store", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
           ),
           ...lockedSounds.map((track) => _buildSoundOption(
              modalContext, 
              setModalState, 
              track, 
              isLocked: true
            )),
        ]
      ],
    );
  }

  Widget _buildSoundOption(BuildContext modalContext, StateSetter setModalState, SoundTrack track, {required bool isLocked}) {
    final assetPath = 'assets/audio/${track.filename}';
    final isCurrentTrack = _selectedSound == track.filename;
    final isActuallyPlaying = isCurrentTrack && _isPlaying;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActuallyPlaying ? Colors.green.withOpacity(0.1) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isLocked ? Icons.lock : track.icon, 
          color: isLocked ? Colors.grey : (isActuallyPlaying ? Colors.green : Colors.grey)
        ),
      ),
      title: Text(track.name, style: TextStyle(color: isActuallyPlaying ? Colors.green : Colors.black87)),
      subtitle: isLocked 
          ? Text("${track.cost} Nectar", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
          : null,
      trailing: isLocked 
          ? ElevatedButton(
              onPressed: () => _handleSoundPurchase(modalContext, setModalState, track),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              child: const Text("Unlock"), 
            )
          : (isActuallyPlaying ? const Icon(Icons.volume_up, color: Colors.green) : null),
      onTap: isLocked 
          ? () => _handleSoundPurchase(modalContext, setModalState, track)
          : () async {
              setModalState(() {
                 _selectedSound = track.filename;
                 _isPlaying = true;
              });
              
              if (mounted) setState(() {
                 _selectedSound = track.filename;
                 _isPlaying = true;
              });
              
              await _audioService.play(assetPath);
              
              await Future.delayed(const Duration(milliseconds: 300));
              if (modalContext.mounted) {
                 Navigator.pop(modalContext);
              }
          },
    );
  }

  Future<void> _handleSoundPurchase(BuildContext modalContext, StateSetter setModalState, SoundTrack track) async {
      final balance = _db.nectar;
      if (balance < track.cost) {
          showDialog(
            context: modalContext,
            builder: (ctx) => AlertDialog(
              title: const Text("Insufficient Nectar"),
              content: Text("You need ${track.cost - balance} more Nectar."),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
            ),
          );
          return;
      }
      
      final confirm = await showDialog<bool>(
        context: modalContext,
        builder: (context) => AlertDialog(
          title: Text("Unlock ${track.name}?"),
          content: Text("Cost: ${track.cost} Nectar"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Buy")),
          ],
        ),
      );

      if (confirm == true) {
         await _db.spendNectar(track.cost);
         await _db.unlockSound(track.id);
         setModalState(() {}); 
         if (mounted) setState(() {}); 
      }
  }

  // --- THEMES ---
  Widget _buildThemeList(BuildContext modalContext, StateSetter setModalState) {
    final unlockedIds = _db.unlockedThemeIds;
    final activeId = _db.activeThemeId;
    final myThemes = ThemeRegistry.allThemes.where((t) => unlockedIds.contains(t.id)).toList();
    final lockedThemes = ThemeRegistry.allThemes.where((t) => !unlockedIds.contains(t.id)).toList();

    return ListView(
      children: [
        if (myThemes.isNotEmpty) ...[
           const Padding(
             padding: EdgeInsets.symmetric(vertical: 8.0),
             child: Text("My Backgrounds", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
           ),
           ...myThemes.map((theme) => _buildThemeOption(
              modalContext, 
              setModalState, 
              theme, 
              isLocked: false,
              isActive: activeId == theme.id,
            )),
        ],
        
        if (lockedThemes.isNotEmpty) ...[
           const Divider(height: 30),
           const Padding(
             padding: EdgeInsets.symmetric(vertical: 8.0),
             child: Text("Wallpaper Store", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
           ),
           ...lockedThemes.map((theme) => _buildThemeOption(
              modalContext, 
              setModalState, 
              theme, 
              isLocked: true,
              isActive: false,
            )),
        ]
      ],
    );
  }

  Widget _buildThemeOption(BuildContext modalContext, StateSetter setModalState, AppTheme theme, {required bool isLocked, required bool isActive}) {
    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
          image: (isLocked || theme.assetPath == null) ? null : DecorationImage(
             image: AssetImage(theme.assetPath!), // Safe bang operator after null check
             fit: BoxFit.cover,
          )
        ),
        child: theme.assetPath == null 
            ? const Icon(Icons.format_paint, color: Colors.black54, size: 20) // Icon for "Clean Slate"
            : (isLocked ? const Icon(Icons.lock, color: Colors.white, size: 20) : null),
      ),
      title: Text(theme.name, style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
      subtitle: isLocked 
          ? Text("${theme.cost} Nectar", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold))
          : (isActive ? const Text("Active", style: TextStyle(color: Colors.green)) : null),
      trailing: isLocked 
          ? ElevatedButton(
              onPressed: () => _handleThemePurchase(modalContext, setModalState, theme),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
              child: const Text("Unlock"), 
            )
          : (isActive ? const Icon(Icons.check_circle, color: Colors.green) : 
              OutlinedButton(
                onPressed: () async {
                   await _db.setActiveTheme(theme.id);
                   setModalState(() {});
                   if (mounted) setState(() {});
                },
                child: const Text("Apply"),
              )
            ),
      onTap: isLocked ? () => _handleThemePurchase(modalContext, setModalState, theme) : null,
    );
  }

  Future<void> _handleThemePurchase(BuildContext modalContext, StateSetter setModalState, AppTheme theme) async {
      final balance = _db.nectar;
      if (balance < theme.cost) {
          showDialog(
            context: modalContext,
            builder: (ctx) => AlertDialog(
              title: const Text("Insufficient Nectar"),
              content: Text("You need ${theme.cost - balance} more Nectar."),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
            ),
          );
          return;
      }
      
      final confirm = await showDialog<bool>(
        context: modalContext,
        builder: (context) => AlertDialog(
          title: Text("Unlock ${theme.name}?"),
          content: Text("Cost: ${theme.cost} Nectar"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Buy")),
          ],
        ),
      );

      if (confirm == true) {
         await _db.spendNectar(theme.cost);
         await _db.unlockTheme(theme.id);
         setModalState(() {}); 
         if (mounted) setState(() {}); 
      }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        Icons.storefront, 
        color: _isPlaying ? Colors.green : Colors.grey, 
        size: 28,
      ),
      onPressed: _showStorePicker,
      tooltip: "Greenhouse Supplies",
    );
  }
}
