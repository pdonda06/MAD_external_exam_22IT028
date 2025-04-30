import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '/widgets/notes_items.dart';

import '../providers/notes.dart';

class NotesScreen extends StatefulWidget {
  static const routeName = '/notes-screen';
  bool isFavouriteScreen;
  NotesScreen({this.isFavouriteScreen = false});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  Future? _futureNotes;

  Future _getFutureNotes() {
    return Provider.of<Notes>(context, listen: false).fetchNotesInfo();
  }

  @override
  void initState() {
    _futureNotes = _getFutureNotes();
    super.initState();
  }

  Widget showMessage(String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              widget.isFavouriteScreen
                  ? Icons.favorite_rounded
                  : Icons.note_alt_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.isFavouriteScreen
                ? 'Add notes to your favorites to see them here'
                : 'Tap the microphone button to create your first note',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final circularProgressIndicator = Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
        strokeWidth: 3,
      ),
    );

    return RefreshIndicator(
      onRefresh: () {
        return Provider.of<Notes>(context, listen: false).fetchNotesInfo();
      },
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withOpacity(0.5),
                      ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: Icon(
                    Icons.filter_list_rounded,
                    color:
                        Theme.of(context).colorScheme.primary.withOpacity(0.5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: Theme.of(context).textTheme.bodyMedium,
                onChanged: (title) {
                  bool isEmpty = title.trim().isEmpty;
                  if (isEmpty) {
                    _getFutureNotes();
                  }
                  Provider.of<Notes>(context, listen: false).searchNotes(title);
                },
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _futureNotes,
              builder: (context, snapshot) {
                if (snapshot.error != null) {
                  return showMessage('Something went wrong!');
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return circularProgressIndicator;
                }
                return Consumer<Notes>(
                  builder: (ctx, notesInfo, _) {
                    if (notesInfo.favNotes.isEmpty &&
                        widget.isFavouriteScreen) {
                      return showMessage('No Favourites added yet!');
                    }
                    if (notesInfo.notes.isEmpty && !widget.isFavouriteScreen) {
                      return showMessage('No notes added yet!');
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: widget.isFavouriteScreen
                          ? notesInfo.favNotes.length
                          : notesInfo.notes.length,
                      itemBuilder: (ctx, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ChangeNotifierProvider.value(
                          value: widget.isFavouriteScreen
                              ? notesInfo.favNotes[index]
                              : notesInfo.notes[index],
                          child: NotesItems(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
