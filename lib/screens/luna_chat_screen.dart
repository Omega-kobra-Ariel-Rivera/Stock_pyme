import 'package:flutter/material.dart';

import '../services/luna_bot_service.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/night_background.dart';

class _Msg {
  final String text;
  final bool fromUser;
  const _Msg(this.text, this.fromUser);
}

class LunaChatScreen extends StatefulWidget {
  final String? initialQuestion;
  const LunaChatScreen({super.key, this.initialQuestion});

  @override
  State<LunaChatScreen> createState() => _LunaChatScreenState();
}

class _LunaChatScreenState extends State<LunaChatScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final List<_Msg> _messages = [];
  bool _typing = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_Msg(LunaBotService.greeting(StorageService.instance.userName), false));
    final q = widget.initialQuestion;
    if (q != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _send(q));
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    final t = text.trim();
    if (t.isEmpty || _typing) return;
    _input.clear();
    setState(() {
      _messages.add(_Msg(t, true));
      _typing = true;
    });
    _scrollDown();
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _messages.add(_Msg(LunaBotService.reply(t), false));
      _typing = false;
    });
    _scrollDown();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.violetB,
              child: Icon(Icons.nights_stay_rounded, color: Colors.white, size: 20),
            ),
            SizedBox(width: 10),
            Text('Luna'),
          ],
        ),
      ),
      body: NightBackground(
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: _messages.length + (_typing ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length) {
                      return const _Bubble(text: 'Luna está escribiendo…', fromUser: false, faded: true);
                    }
                    final m = _messages[i];
                    return _Bubble(text: m.text, fromUser: m.fromUser);
                  },
                ),
              ),
              SizedBox(
                height: 46,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final s in LunaBotService.suggestions)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(s),
                          backgroundColor: AppColors.card,
                          side: const BorderSide(color: AppColors.cardBorder),
                          labelStyle: const TextStyle(color: Colors.white),
                          onPressed: () => _send(s),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _input,
                        style: const TextStyle(color: Colors.white),
                        textInputAction: TextInputAction.send,
                        onSubmitted: _send,
                        decoration: InputDecoration(
                          hintText: 'Pregúntale a Luna…',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.card,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(28),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: () => _send(_input.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool fromUser;
  final bool faded;
  const _Bubble({required this.text, required this.fromUser, this.faded = false});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: fromUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.8),
        decoration: BoxDecoration(
          gradient: fromUser
              ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryLight])
              : null,
          color: fromUser ? null : AppColors.card,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(fromUser ? 20 : 6),
            bottomRight: Radius.circular(fromUser ? 6 : 20),
          ),
          border: fromUser ? null : Border.all(color: AppColors.cardBorder),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: faded ? AppColors.textMuted : Colors.white,
            fontSize: 16,
            height: 1.4,
            fontStyle: faded ? FontStyle.italic : FontStyle.normal,
          ),
        ),
      ),
    );
  }
}
