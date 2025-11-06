import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/desktop_theme.dart';
import '../widgets/glassmorphism.dart';

/// Command palette for keyboard-driven workflows (like Notion, Linear)
/// Triggered by Cmd+K (macOS) or Ctrl+K (Windows/Linux)
class CommandPalette extends StatefulWidget {
  const CommandPalette({
    super.key,
    required this.commands,
  });

  final List<Command> commands;

  @override
  State<CommandPalette> createState() => _CommandPaletteState();
}

class _CommandPaletteState extends State<CommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  List<Command> _filteredCommands = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _filteredCommands = widget.commands;
    _searchController.addListener(_filterCommands);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCommands() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCommands = widget.commands
          .where((cmd) =>
              cmd.title.toLowerCase().contains(query) ||
              cmd.subtitle.toLowerCase().contains(query))
          .toList();
      _selectedIndex = 0;
    });
  }

  void _executeCommand(Command command) {
    Navigator.of(context).pop();
    command.onExecute();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Focus(
        autofocus: true,
        onKey: (node, event) {
          if (event is RawKeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
              setState(() {
                _selectedIndex = (_selectedIndex + 1) % _filteredCommands.length;
              });
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
              setState(() {
                _selectedIndex = (_selectedIndex - 1) % _filteredCommands.length;
                if (_selectedIndex < 0) _selectedIndex = _filteredCommands.length - 1;
              });
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.enter) {
              if (_filteredCommands.isNotEmpty) {
                _executeCommand(_filteredCommands[_selectedIndex]);
              }
              return KeyEventResult.handled;
            } else if (event.logicalKey == LogicalKeyboardKey.escape) {
              Navigator.of(context).pop();
              return KeyEventResult.handled;
            }
          }
          return KeyEventResult.ignored;
        },
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Glassmorphism(
            blur: 40,
            opacity: 0.1,
            borderRadius: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Search input
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: DesktopTheme.darkTextSecondary,
                        size: 24,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: const TextStyle(
                            fontSize: 18,
                            color: DesktopTheme.darkText,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Type a command or search...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: DesktopTheme.darkTextSecondary,
                            ),
                          ),
                        ),
                      ),
                      // Keyboard hint
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: DesktopTheme.darkCard.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: DesktopTheme.darkBorder.withOpacity(0.5),
                          ),
                        ),
                        child: const Text(
                          'ESC',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: DesktopTheme.darkTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 1,
                  color: DesktopTheme.darkBorder.withOpacity(0.3),
                ),

                // Commands list
                Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: _filteredCommands.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredCommands.length,
                          itemBuilder: (context, index) {
                            final command = _filteredCommands[index];
                            final isSelected = index == _selectedIndex;

                            return InkWell(
                              onTap: () => _executeCommand(command),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                color: isSelected
                                    ? DesktopTheme.primaryPurple.withOpacity(0.2)
                                    : Colors.transparent,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: isSelected
                                            ? DesktopTheme.purpleGradient
                                            : null,
                                        color: isSelected
                                            ? null
                                            : DesktopTheme.darkCard,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        command.icon,
                                        size: 20,
                                        color: isSelected
                                            ? Colors.white
                                            : DesktopTheme.darkTextSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            command.title,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                              color: isSelected
                                                  ? DesktopTheme.darkText
                                                  : DesktopTheme.darkText,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            command.subtitle,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              color:
                                                  DesktopTheme.darkTextSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (command.shortcut != null)
                                      _buildShortcutBadge(command.shortcut!),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.all(48),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 48,
              color: DesktopTheme.darkTextSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No commands found',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: DesktopTheme.darkTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShortcutBadge(String shortcut) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: DesktopTheme.darkCard.withOpacity(0.5),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: DesktopTheme.darkBorder.withOpacity(0.5),
        ),
      ),
      child: Text(
        shortcut,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: DesktopTheme.darkTextSecondary,
        ),
      ),
    );
  }
}

/// Command model for command palette
class Command {
  const Command({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onExecute,
    this.shortcut,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onExecute;
  final String? shortcut;
}
