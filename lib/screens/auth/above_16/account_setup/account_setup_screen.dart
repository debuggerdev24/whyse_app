import 'package:redstreakapp/core/constants/app_constants.dart';
import 'package:redstreakapp/core/utils/app_imports.dart';
import 'package:redstreakapp/core/utils/custom_loader.dart';
import 'package:redstreakapp/providers/auth/auth_provider.dart';
import 'package:redstreakapp/providers/on_boarding/on_boarding_provider.dart';
import 'package:redstreakapp/screens/auth/above_16/account_setup/models/onboarding_chat_models.dart';
import 'package:redstreakapp/screens/auth/above_16/account_setup/widgets/account_setup_widgets.dart';

class AccountSetupScreen extends StatefulWidget {
  const AccountSetupScreen({super.key, this.initialStep});

  final String? initialStep;

  @override
  State<AccountSetupScreen> createState() => _AccountSetupScreenState();
}

class _AccountSetupScreenState extends State<AccountSetupScreen> {
  static const _readingOptions = ['5 min', '10 min', '20 min'];

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<OnboardingChatItem> _items = [];
  AccountSetupStep _currentStep = AccountSetupStep.country;
  int _itemCounter = 0;
  bool _isBusy = false;

  String? _selectedCountry;
  String? _selectedLanguage;
  final Set<String> _selectedInterestIds = {};
  final Set<String> _selectedTopicIds = {};
  final Set<String> _selectedGoalIds = {};
  final List<String> _customInterests = [];
  final List<String> _customTopics = [];
  final List<String> _customGoalTitles = [];

  @override
  void initState() {
    super.initState();
    _currentStep = _resolveInitialStep(widget.initialStep);
    _bootstrapFlow();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _prefetchStepData();
      if (mounted) {
        _restoreFromCachedOnboardingProgress();
      }
    });
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  AccountSetupStep _resolveInitialStep(String? step) {
    switch (step) {
      case AppConstants.readingGoal:
        return AccountSetupStep.readingGoal;
      case AppConstants.interest:
        return AccountSetupStep.interests;
      case AppConstants.topics:
        return AccountSetupStep.topics;
      case AppConstants.goals:
        return AccountSetupStep.goals;
      default:
        return AccountSetupStep.country;
    }
  }

  Future<void> _prefetchStepData() async {
    final auth = context.read<AuthProvider>();
    if (_currentStep.index >= AccountSetupStep.interests.index) {
      await auth.fetchDefaultInterests(context);
    }
    if (_currentStep.index >= AccountSetupStep.topics.index) {
      await auth.fetchDefaultTopics(context);
    }
    if (_currentStep.index >= AccountSetupStep.goals.index) {
      await auth.getGoals(context);
    }
  }

  void _bootstrapFlow() {
    _items.clear();
    if (_currentStep == AccountSetupStep.country) {
      _appendBotAndPicker(
        '**Hello!** I\'m here to help you setup your ReadstreakApp account. Please tell me where you are situated:',
        OnboardingChatItemType.countryPicker,
      );
      return;
    }
    if (_currentStep == AccountSetupStep.language) {
      _appendBotAndPicker(
        '**Hello!** I\'m here to help you setup your ReadstreakApp account. Please tell me where you are situated:',
        OnboardingChatItemType.countryPicker,
        active: false,
      );
      _appendBotAndPicker(
        '**Awesome!** Next I would like to know your preferred language.',
        OnboardingChatItemType.languagePicker,
      );
      return;
    }
    if (_currentStep == AccountSetupStep.readingGoal) {
      _restoreThroughLanguage();
      _appendBotAndPicker(
        '**Great!** Now tell me how much do you aim to read daily?',
        OnboardingChatItemType.readingGoalPicker,
      );
      return;
    }
    if (_currentStep == AccountSetupStep.interests) {
      _restoreThroughReadingGoal();
      _appendBotAndPicker(
        '**Awesome!** Now let\'s pick your interests.',
        OnboardingChatItemType.interestPicker,
      );
      return;
    }
    if (_currentStep == AccountSetupStep.topics) {
      _restoreThroughInterests();
      _appendBotAndPicker(
        '**Great!** Now tell me what topics you would like to read about.',
        OnboardingChatItemType.topicPicker,
      );
      return;
    }
    if (_currentStep == AccountSetupStep.goals) {
      _restoreThroughTopics();
      _appendBotAndPicker(
        '**Great!** Now tell me what motivates you the most.',
        OnboardingChatItemType.goalPicker,
      );
    }
  }

  void _restoreThroughLanguage() {
    _items.addAll([
      _bot(
        '**Hello!** I\'m here to help you setup your ReadstreakApp account. Please tell me where you are situated:',
      ),
      _user('Your country'),
      _bot('**Awesome!** Next I would like to know your preferred language.'),
      _user('Your language'),
    ]);
  }

  void _restoreThroughReadingGoal() {
    _restoreThroughLanguage();
    _items.addAll([
      _bot('**Great!** Now tell me how much do you aim to read daily?'),
      _user('Your reading goal'),
    ]);
  }

  void _restoreThroughInterests() {
    _restoreThroughReadingGoal();
    _items.addAll([
      _bot('**Awesome!** Now let\'s pick your interests.'),
      _user('Your interests'),
    ]);
  }

  void _restoreThroughTopics() {
    _restoreThroughInterests();
    _items.addAll([
      _bot('**Great!** Now tell me what topics you would like to read about.'),
      _user('Your topics'),
    ]);
  }

  String _nextId() => 'setup_${++_itemCounter}';

  OnboardingChatItem _bot(String text) => OnboardingChatItem(
        id: _nextId(),
        type: OnboardingChatItemType.botMessage,
        botText: text,
      );

  OnboardingChatItem _user(String text) => OnboardingChatItem(
        id: _nextId(),
        type: OnboardingChatItemType.userMessage,
        userText: text,
      );

  void _appendBotAndPicker(
    String botText,
    OnboardingChatItemType pickerType, {
    bool active = true,
  }) {
    _items.add(
      OnboardingChatItem(
        id: _nextId(),
        type: OnboardingChatItemType.botMessage,
        botText: botText,
      ),
    );
    _items.add(
      OnboardingChatItem(
        id: _nextId(),
        type: pickerType,
        isActive: active,
      ),
    );
  }

  void _deactivatePickers() {
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (_isPickerType(item.type) && item.isActive) {
        _items[i] = item.copyWith(isActive: false);
      }
    }
  }

  bool _isPickerType(OnboardingChatItemType type) {
    return type != OnboardingChatItemType.botMessage &&
        type != OnboardingChatItemType.userMessage;
  }

  Future<void> _onCountrySelected(String country) async {
    if (_isBusy || _currentStep != AccountSetupStep.country) return;
    setState(() {
      _selectedCountry = country;
    });
    context.read<OnBoardingProvider>().setCountry(country);
    _deactivatePickers();
    _items.add(_user(country));

    setState(() {
      _currentStep = AccountSetupStep.language;
      _appendBotAndPicker(
        '**Awesome!** Next I would like to know your preferred language.',
        OnboardingChatItemType.languagePicker,
      );
    });
    _scrollToBottom();
  }

  Future<void> _onLanguageSelected(String language) async {
    if (_isBusy || _currentStep != AccountSetupStep.language) return;
    setState(() {
      _selectedLanguage = language;
      _isBusy = true;
    });
    context.read<OnBoardingProvider>().setLanguage(language);
    _deactivatePickers();
    _items.add(_user(language));

    final success = await context.read<AuthProvider>().saveProfileInfo(
          context,
          country: _selectedCountry!,
          preferredLanguage: language,
        );

    if (!mounted) return;
    if (!success) {
      setState(() => _isBusy = false);
      return;
    }

    setState(() {
      _isBusy = false;
      _currentStep = AccountSetupStep.readingGoal;
      _appendBotAndPicker(
        '**Great!** Now tell me how much do you aim to read daily?',
        OnboardingChatItemType.readingGoalPicker,
      );
    });
    _scrollToBottom();
  }

  Future<void> _onReadingGoalSelected(String option) async {
    if (_isBusy || _currentStep != AccountSetupStep.readingGoal) return;
    final minutes = int.tryParse(option.split(' ').first) ?? 0;
    if (minutes <= 0) return;

    setState(() => _isBusy = true);
    _deactivatePickers();
    _items.add(_user(option));

    final success = await context.read<AuthProvider>().saveReadingGoal(
          context,
          dailyReadingGoal: minutes,
        );

    if (!mounted) return;
    if (!success) {
      setState(() => _isBusy = false);
      return;
    }

    await context.read<AuthProvider>().fetchDefaultInterests(context);
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      _currentStep = AccountSetupStep.interests;
      _selectedInterestIds.clear();
      _appendBotAndPicker(
        '**Awesome!** Now let\'s pick your interests.',
        OnboardingChatItemType.interestPicker,
      );
    });
    _scrollToBottom();
  }

  String? _consumeInputText() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return null;
    _inputController.clear();
    return text;
  }

  void _appendCustomInterest(String name) {
    if (!_customInterests.contains(name)) {
      _customInterests.add(name);
    }
  }

  void _appendCustomTopic(String title) {
    if (!_customTopics.contains(title)) {
      _customTopics.add(title);
    }
  }

  void _appendCustomGoal(String title) {
    if (!_customGoalTitles.contains(title)) {
      _customGoalTitles.add(title);
    }
  }

  void _restoreFromCachedOnboardingProgress() {
    final progress = context.read<AuthProvider>().cachedOnboardingProgress;
    if (progress == null) return;

    final onboardingProvider = context.read<OnBoardingProvider>();
    final auth = context.read<AuthProvider>();
    var changed = false;

    final profile = progress.userProfile;
    if (profile?.country != null && profile!.country!.isNotEmpty) {
      _selectedCountry = profile.country;
      onboardingProvider.setCountry(profile.country!);
      changed = true;
    }
    if (profile?.preferredLanguage != null &&
        profile!.preferredLanguage!.isNotEmpty) {
      _selectedLanguage = profile.preferredLanguage;
      onboardingProvider.setLanguage(profile.preferredLanguage!);
      changed = true;
    }

    if (progress.userInterests != null) {
      for (final item in progress.userInterests!) {
        final interestId = item.interestId?.toString();
        if (interestId != null && interestId.isNotEmpty) {
          _selectedInterestIds.add(interestId);
          changed = true;
        }
        final customName = item.customName?.toString().trim();
        if (customName != null && customName.isNotEmpty) {
          _appendCustomInterest(customName);
          changed = true;
        }
      }
    }

    if (progress.userTopics != null) {
      for (final item in progress.userTopics!) {
        final topicId = item.topicId?.toString();
        if (topicId != null && topicId.isNotEmpty) {
          _selectedTopicIds.add(topicId);
          changed = true;
        }
        final customName = item.customName?.toString().trim();
        if (customName != null && customName.isNotEmpty) {
          _appendCustomTopic(customName);
          changed = true;
        }
      }
    }

    if (progress.userGoals != null) {
      for (final item in progress.userGoals!) {
        if (item.isCustom == true) {
          final title = item.title?.trim();
          if (title != null && title.isNotEmpty) {
            _appendCustomGoal(title);
            changed = true;
          }
        } else {
          final goalId = item.goalId?.toString();
          if (goalId != null && goalId.isNotEmpty) {
            _selectedGoalIds.add(goalId);
            auth.selectedGoalIds.add(goalId);
            changed = true;
          }
        }
      }
    }

    if (changed) {
      setState(() {});
    }
  }

  Future<void> _submitInterests() async {
    if (_isBusy || _currentStep != AccountSetupStep.interests) return;

    final pendingCustom = _consumeInputText();
    if (pendingCustom != null) {
      _appendCustomInterest(pendingCustom);
    }

    if (_selectedInterestIds.isEmpty && _customInterests.isEmpty) {
      AppToast.error(context, 'Please select at least one interest');
      return;
    }

    final auth = context.read<AuthProvider>();
    final labels = auth.interestsList
        .where((item) => _selectedInterestIds.contains(item['id']))
        .map((item) => item['name']?.toString() ?? '')
        .where((name) => name.isNotEmpty)
        .toList()
      ..addAll(_customInterests);

    setState(() => _isBusy = true);
    _deactivatePickers();
    _items.add(_user(labels.join(', ')));

    final success = await auth.saveInterests(
      context,
      interestIds: _selectedInterestIds.toList(),
      customInterests: List<String>.from(_customInterests),
    );

    if (!mounted) return;
    if (!success) {
      setState(() => _isBusy = false);
      return;
    }

    await auth.fetchDefaultTopics(context);
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      _currentStep = AccountSetupStep.topics;
      _selectedTopicIds.clear();
      _customInterests.clear();
      _appendBotAndPicker(
        '**Great!** Now tell me what topics you would like to read about.',
        OnboardingChatItemType.topicPicker,
      );
    });
    _scrollToBottom();
  }

  Future<void> _submitTopics() async {
    if (_isBusy || _currentStep != AccountSetupStep.topics) return;

    final pendingCustom = _consumeInputText();
    if (pendingCustom != null) {
      _appendCustomTopic(pendingCustom);
    }

    if (_selectedTopicIds.isEmpty && _customTopics.isEmpty) {
      AppToast.error(context, 'Please select at least one topic');
      return;
    }

    final auth = context.read<AuthProvider>();
    final labels = auth.topicsList
        .where((item) => _selectedTopicIds.contains(item['id']))
        .map((item) => item['title']?.toString() ?? '')
        .where((title) => title.isNotEmpty)
        .toList()
      ..addAll(_customTopics);

    setState(() => _isBusy = true);
    _deactivatePickers();
    final summary = labels.isEmpty
        ? 'Selected topics'
        : labels.asMap().entries.map((e) => '${e.key + 1}. ${e.value}').join('\n');
    _items.add(_user(summary));

    final success = await auth.saveTopics(
      context,
      topicIds: _selectedTopicIds.toList(),
      customTopics: List<String>.from(_customTopics),
    );

    if (!mounted) return;
    if (!success) {
      setState(() => _isBusy = false);
      return;
    }

    await auth.getGoals(context);
    if (!mounted) return;

    setState(() {
      _isBusy = false;
      _currentStep = AccountSetupStep.goals;
      _selectedGoalIds.clear();
      _customTopics.clear();
      auth.selectedGoalIds.clear();
      _appendBotAndPicker(
        '**Great!** Now tell me what motivates you the most.',
        OnboardingChatItemType.goalPicker,
      );
    });
    _scrollToBottom();
  }

  Future<void> _submitGoals() async {
    if (_isBusy || _currentStep != AccountSetupStep.goals) return;

    final pendingCustom = _consumeInputText();
    if (pendingCustom != null) {
      _appendCustomGoal(pendingCustom);
    }

    if (_selectedGoalIds.isEmpty && _customGoalTitles.isEmpty) {
      AppToast.error(context, 'Please select at least one goal');
      return;
    }

    final auth = context.read<AuthProvider>();
    final labels = auth.goalsList
        .where((item) => _selectedGoalIds.contains(item['id']))
        .map((item) => item['title']?.toString() ?? '')
        .where((title) => title.isNotEmpty)
        .toList()
      ..addAll(_customGoalTitles);

    setState(() => _isBusy = true);
    _deactivatePickers();
    _items.add(_user(labels.join(', ')));

    final success = await auth.saveGoals(
      context,
      goalIds: _selectedGoalIds.toList(),
      customGoals: _customGoalTitles
          .map(
            (title) => {
              'title': title,
              'description': title,
            },
          )
          .toList(),
    );

    if (!mounted) return;
    if (!success) {
      setState(() => _isBusy = false);
      return;
    }

    setState(() {
      _isBusy = false;
      _currentStep = AccountSetupStep.finished;
      _customGoalTitles.clear();
    });

    context.pushNamed(AppRoutes.successScreen.name);
  }

  void _handleSend() {
    switch (_currentStep) {
      case AccountSetupStep.interests:
        _submitInterests();
      case AccountSetupStep.topics:
        _submitTopics();
      case AccountSetupStep.goals:
        _submitGoals();
      default:
        break;
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  bool get _canUseInputBar {
    return _currentStep == AccountSetupStep.interests ||
        _currentStep == AccountSetupStep.topics ||
        _currentStep == AccountSetupStep.goals;
  }

  String get _inputHintText {
    switch (_currentStep) {
      case AccountSetupStep.interests:
        return 'Add custom interest...';
      case AccountSetupStep.topics:
        return 'Add custom topic...';
      case AccountSetupStep.goals:
        return 'Add custom goal...';
      default:
        return 'Type here';
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.goNamed(AppRoutes.loginScreen.name);
      },
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: accountSetupBackground,
            body: Column(
              children: [
                const AccountSetupHeader(),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: _buildItem(item, auth),
                      );
                    },
                  ),
                ),
                AccountSetupInputBar(
                  controller: _inputController,
                  enabled: _canUseInputBar && !_isBusy,
                  hintText: _canUseInputBar ? _inputHintText : 'Type here',
                  onSend: _handleSend,
                ),
              ],
            ),
          ),
          if (_isBusy ||
              auth.isSaveProfileLoading ||
              auth.isSaveReadingGoal ||
              auth.isSaveInterestLoading ||
              auth.isSaveTopicsLoading ||
              auth.isSaveGoalsLoading)
            const FullPageIndicator(),
        ],
      ),
    );
  }

  Widget _buildItem(OnboardingChatItem item, AuthProvider auth) {
    switch (item.type) {
      case OnboardingChatItemType.botMessage:
        return AccountSetupBotBubble(text: item.botText ?? '');
      case OnboardingChatItemType.userMessage:
        return AccountSetupUserBubble(text: item.userText ?? '');
      case OnboardingChatItemType.countryPicker:
        if (!item.isActive) return const SizedBox.shrink();
        return AccountSetupDropdownField(
          hint: 'Select Country',
          items: accountSetupCountries,
          value: _selectedCountry,
          onChanged: (value) {
            if (value != null) _onCountrySelected(value);
          },
        );
      case OnboardingChatItemType.languagePicker:
        if (!item.isActive) return const SizedBox.shrink();
        return AccountSetupDropdownField(
          hint: 'Select Preferred Language',
          items: accountSetupLanguages,
          value: _selectedLanguage,
          onChanged: (value) {
            if (value != null) _onLanguageSelected(value);
          },
        );
      case OnboardingChatItemType.readingGoalPicker:
        if (!item.isActive) return const SizedBox.shrink();
        return AccountSetupReadingPills(
          options: _readingOptions,
          onSelected: _onReadingGoalSelected,
        );
      case OnboardingChatItemType.interestPicker:
        if (!item.isActive) return const SizedBox.shrink();
        if (auth.isLoadingInterests) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
          );
        }
        return Column(
          children: [
            ...auth.interestsList.map((interest) {
              final id = interest['id']?.toString() ?? '';
              final name = interest['name']?.toString() ?? '';
              return AccountSetupInterestChip(
                label: name,
                iconPath: iconForInterestName(name),
                isSelected: _selectedInterestIds.contains(id),
                onTap: () {
                  setState(() {
                    if (_selectedInterestIds.contains(id)) {
                      _selectedInterestIds.remove(id);
                    } else {
                      _selectedInterestIds.add(id);
                    }
                  });
                },
              );
            }),
            ..._customInterests.map(
              (name) => AccountSetupInterestChip(
                label: name,
                iconPath: iconForInterestName(name),
                isSelected: true,
                onTap: () {
                  setState(() => _customInterests.remove(name));
                },
              ),
            ),
          ],
        );
      case OnboardingChatItemType.topicPicker:
        if (!item.isActive) return const SizedBox.shrink();
        if (auth.isLoadingTopics) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
          );
        }
        return Column(
          children: [
            ...auth.topicsList.map((topic) {
              final id = topic['id']?.toString() ?? '';
              final title = topic['title']?.toString() ?? '';
              final thumb = topic['thumbnailUrl']?.toString() ?? '';
              return AccountSetupTopicChip(
                label: title,
                imagePath: thumb.isNotEmpty
                    ? thumb
                    : imageForTopicTitle(title),
                isSelected: _selectedTopicIds.contains(id),
                onTap: () {
                  setState(() {
                    if (_selectedTopicIds.contains(id)) {
                      _selectedTopicIds.remove(id);
                    } else {
                      _selectedTopicIds.add(id);
                    }
                  });
                },
              );
            }),
            ..._customTopics.map(
              (title) => AccountSetupTopicChip(
                label: title,
                imagePath: imageForTopicTitle(title),
                isSelected: true,
                onTap: () {
                  setState(() => _customTopics.remove(title));
                },
              ),
            ),
          ],
        );
      case OnboardingChatItemType.goalPicker:
        if (!item.isActive) return const SizedBox.shrink();
        if (auth.isLoadingGoals) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.teal),
            ),
          );
        }
        return Column(
          children: [
            ...auth.goalsList.map((goal) {
              final id = goal['id']?.toString() ?? '';
              final title = goal['title']?.toString() ?? '';
              final description = goal['description']?.toString() ?? '';
              return AccountSetupGoalCard(
                title: title,
                description: description,
                isSelected: _selectedGoalIds.contains(id),
                onTap: () {
                  setState(() {
                    auth.toggleGoal(id);
                    _selectedGoalIds
                      ..clear()
                      ..addAll(auth.selectedGoalIds);
                  });
                },
              );
            }),
            ..._customGoalTitles.map(
              (title) => AccountSetupGoalCard(
                title: title,
                description: title,
                isSelected: true,
                onTap: () {
                  setState(() => _customGoalTitles.remove(title));
                },
              ),
            ),
          ],
        );
    }
  }
}
