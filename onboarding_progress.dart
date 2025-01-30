// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_promova_app2/constants/colors.dart';
import 'package:lottie/lottie.dart';

import '../../../dialogs/dialog_helper.dart';
import '../../../models/extra_data_model.dart';
import 'signup_signin_form.dart';

class OnboardingProgressScreen extends StatefulWidget {
  final Future<EDM_Onbprdata_ApiResponse?> mainData;
  final Future<EDM_Onb_pr> data;
  const OnboardingProgressScreen(
      {super.key, required this.mainData, required this.data});

  @override
  _OnboardingProgressScreenState createState() =>
      _OnboardingProgressScreenState();
}

class _OnboardingProgressScreenState extends State<OnboardingProgressScreen>
    with SingleTickerProviderStateMixin {
  int _currentLevel = 0;
  double _progress = 1 / 6;
  final PageController _pageController = PageController();
  double _animatedProgress = 0.2;
  late AnimationController _controller;
  late Animation<double> _animation;

  int _choiceLanguage = -1;
  int _choiceLanguageLevel = -1;
  int _choiceLanguageReason = -1;
  int _choiceTimePractice = -1;
  int _choiceSkill = -1;

  String? _firstName;
  String? _lastName;
  String? _selectedAgeItem;
  int? _ageSelectIndex;
  String? _selectedGenderItem;
  int? _genderSelectIndex;

  bool _showDoneAnimation = false;
  bool _showLottieText = false;

  final TextEditingController _tfCntrl_firstName = TextEditingController();
  String? _tfem_first_name;

  final TextEditingController _tfCntrl_lastName = TextEditingController();
  String? _tfem_last_name;

  String? _tfem_age;
  String? _tfem_gender;

  bool _validateAndSubmit() {
    setState(() {
      _tfem_first_name = _tfCntrl_firstName.text.isEmpty
          ? 'Please enter your first name'
          : null;
      _tfem_last_name =
          _tfCntrl_lastName.text.isEmpty ? 'Please enter your last name' : null;
      _tfem_age = _selectedAgeItem == null ? 'Please select your age' : null;
      _tfem_gender =
          _selectedGenderItem == null ? 'Please select your gender' : null;
    });

    return _tfem_first_name == null &&
        _tfem_last_name == null &&
        _tfem_age == null &&
        _tfem_gender == null;
  }

  List<EDM_Onbprdata_Item> languagesData = [];
  List<EDM_Onb_pr_Language> otherLanguagesData = [];
  List<EDM_Onbprdata_Item> levels = [];
  List<EDM_Onb_pr_Level> otherLevelsData = [];
  List<EDM_Onbprdata_Item> reasons = [];
  List<EDM_Onbprdata_Item> skills = [];
  List<EDM_Onbprdata_Item> timePractice = [];
  List<EDM_Onbprdata_Item> topics = [];

  final List<String> languageLevelsName = [
    "A1",
    "A1",
    "A2",
    "B1",
    "B2",
    "C1",
    "C2"
  ];
  final Set<int> _selectedSkills = {};
  final List<String> _ageItems = [
    'under 10',
    '10 - 15',
    '15 - 25',
    '25 - 35',
    '35 - 50',
    'other'
  ];
  final List<String> _genderItems = ['male', 'female', 'prefer to not say'];

  void _goToNextLevel() {
    setState(() {
      _currentLevel++;

      _progress += 1 / 7;

      _animation = Tween<double>(begin: _animatedProgress, end: _progress)
          .animate(_controller);
      _controller.forward(from: 0);

      _pageController.animateToPage(
        _currentLevel,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      _animatedProgress = _progress;
    });
  }

  void _goBack() {
    setState(() {
      if (_currentLevel > 0) {
        double previousProgress = _progress;

        _currentLevel--;

        _progress -= 1 / 7;

        _animation = Tween<double>(begin: previousProgress, end: _progress)
            .animate(_controller);
        _controller.forward(from: 0);

        _pageController.animateToPage(
          _currentLevel,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );

        _animatedProgress = _progress;
      } else {
        Navigator.pop(context);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation =
        Tween<double>(begin: _progress, end: _progress).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: FutureBuilder<EDM_Onbprdata_ApiResponse?>(
        future: widget.mainData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error: ${snapshot.error}");
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Text("No data available");
          } else {
            EDM_Onbprdata_Model data = snapshot.data!.data;

            return FutureBuilder<EDM_Onb_pr>(
                future: widget.data,
                builder: (context, dataSnapshot) {
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (dataSnapshot.hasError) {
                    return Text("Error: ${dataSnapshot.error}");
                  } else if (!dataSnapshot.hasData ||
                      dataSnapshot.data == null) {
                    return const Text("No additional data available");
                  } else {
                    EDM_Onb_pr additionalData = dataSnapshot.data!;
                    otherLanguagesData = additionalData.languages;
                    languagesData = data.languages;
                    levels = data.levels;
                    otherLevelsData = additionalData.levels;
                    reasons = data.reasons;
                    skills = data.skills;
                    timePractice = data.timePractice;
                    topics = data.topics;
                    return Stack(
                      children: [
                        Column(
                          children: [
                            getTopButtons(context),
                            const SizedBox(height: 5),
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return LinearProgressIndicator(
                                  value: _animation.value,
                                  minHeight: 10,
                                  color: AppColors.appcolors_blue1,
                                  backgroundColor: AppColors.appcolors_blue1
                                      .withValues(alpha: 0.2),
                                );
                              },
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 40, bottom: 10, left: 10, right: 10),
                                child: PageView(
                                  controller: _pageController,
                                  physics:
                                      const NeverScrollableScrollPhysics(), // Disable swipe gestures
                                  children: [
                                    _buildLevel1(data.languages,
                                        additionalData.languages),
                                    _buildLevel2(),
                                    _buildLevel3(),
                                    _buildLevel4(),
                                    _buildLevel5(),
                                    _buildLevel6()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_showDoneAnimation)
                          Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: MediaQuery.sizeOf(context).height,
                            color: Colors.black.withOpacity(0.8),
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 50),
                                child: SizedBox(
                                  height: 500,
                                  width: MediaQuery.sizeOf(context).width,
                                  child: Stack(
                                    children: [
                                      Container(
                                        height: 400,
                                        width: MediaQuery.sizeOf(context).width,
                                        child: Center(
                                          child: Lottie.asset(
                                              'assets/anims/done-anim.json',
                                              width: 300,
                                              height: 300,
                                              fit: BoxFit.fill,
                                              repeat: false),
                                        ),
                                      ),
                                      if (_showLottieText)
                                        const Positioned(
                                          right: 0,
                                          left: 0,
                                          top: 260,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 20.0, right: 20, left: 20),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  "Personalization in progress",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                SizedBox(height: 20),
                                                Text(
                                                  "your personal plan is almost ready.",
                                                  style: TextStyle(
                                                    color: Colors.white60,
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  }
                });
          }
        },
      )),
    );
  }

  Widget getTopButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(13.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: const TextSpan(
              text: '#',
              style: TextStyle(
                  fontSize: 20,
                  color: AppColors.appcolors_blue1,
                  fontWeight: FontWeight.w300),
              children: <TextSpan>[
                TextSpan(
                  text: '1',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.appcolors_blue1,
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: AppColors.appcolors_blue1),
            child: Image.asset(
              'assets/images/ic_launcher_main_hand.webp',
              width: 70,
              height: 70,
            ),
          ),
        ],
      ),
    );
  }

  // Level 1: Language selection
  Widget _buildLevel1(List<EDM_Onbprdata_Item> mylanguages,
      List<EDM_Onb_pr_Language> additionalLanData) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _goBack,
            ),
            const SizedBox(
              width: 5,
            ),
            const Expanded(
              child: Text(
                'Which language do you want to learn?',
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shrinkWrap: true,
            itemCount: mylanguages.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.0,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _choiceLanguage = index;
                  _goToNextLevel();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (index == _choiceLanguage)
                          ? AppColors.appcolors_blue1
                          : AppColors.appcolors_pinky,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.network(mylanguages[index].icon ?? "", width: 40, height: 40),
                              const SizedBox(height: 10),
                              Text(
                                mylanguages[index].title,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: (index == _choiceLanguage)
                                      ? AppColors.appcolors_blue1
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!additionalLanData[index].enable)
                        GestureDetector(
                          onTap: () {
                            // show comming soon dialog
                            setState(() {
                              _choiceLanguage = index;
                            });
                            DialogHelper.showSimpleDialog(
                                title: "Comming Soon",
                                context: context,
                                contentText:
                                    "${mylanguages[index].title} Language is currently disabled. ${mylanguages[index].title} will be added to the list of Number1 languages, soon.",
                                contentTextColor: Colors.black,
                                subText: " ${mylanguages[index].icon} ",
                                hasCancelIcon: true,
                                canCancel: true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 10),
                            height: double.infinity,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (index == _choiceLanguage)
                                    ? AppColors.appcolors_blue1
                                    : AppColors.appcolors_pinky,
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  color: Colors.white70,
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Comming Soon",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Level 2: Select language skill level
  Widget _buildLevel2() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: _goBack,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    // Ensure the text takes up remaining space
                    child: Text(
                      'What is your ${(_choiceLanguage != -1) ? languagesData[_choiceLanguage].title : languagesData[0].title} level?',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      softWrap: true, // Allow text to wrap to the next line
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                showLanguageBottomSheet(context);
              },
              icon: const Icon(Icons.info_outline),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          // Expanded to let ListView take available space
          child: ListView.builder(
            padding:
                const EdgeInsets.symmetric(horizontal: 10), // Added padding
            itemCount: levels.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _choiceLanguageLevel = index;
                  _goToNextLevel();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: (index == _choiceLanguageLevel)
                          ? AppColors.appcolors_blue1
                          : AppColors.appcolors_pinky,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        levels[index].title,
                        style: TextStyle(
                          color: (index == _choiceLanguageLevel)
                              ? AppColors.appcolors_blue1
                              : Colors.black,
                        ),
                      ),
                      Text(
                        languageLevelsName[index],
                        style: TextStyle(
                          color: (index == _choiceLanguageLevel)
                              ? AppColors.appcolors_blue1
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Level 3: Select learning reason
  Widget _buildLevel3() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              ),
              const SizedBox(width: 5),
              Flexible(
                // Use Flexible inside Row to allow flexible width allocation
                child: Text(
                  'What is your primary reason for learning ${(_choiceLanguage != -1) ? languagesData[_choiceLanguage].title : ""}?',
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true, // Allows text to wrap to the next line
                  overflow: TextOverflow
                      .visible, // Ensures text is visible and not truncated
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Using Column instead of ListView.builder, since we're already in SingleChildScrollView
          Column(
            children: List.generate(
              reasons.length,
              (index) {
                return GestureDetector(
                  onTap: () {
                    _choiceLanguageReason = index;
                    _goToNextLevel();
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 20), // Added margin
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (index == _choiceLanguageReason)
                            ? AppColors.appcolors_blue1
                            : AppColors.appcolors_pinky,
                      ),
                    ),
                    child: Text(
                      reasons[index].title,
                      style: TextStyle(
                        fontSize: 15,
                        color: (index == _choiceLanguageReason)
                            ? AppColors.appcolors_blue1
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Level 4: Select practice time
  Widget _buildLevel4() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              ),
              const SizedBox(width: 5),
              const Flexible(
                // Use Flexible instead of Expanded to allow flexible width allocation
                child: Text(
                  'How often do you want to practice?',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true, // Allows text to wrap to the next line
                  overflow: TextOverflow
                      .visible, // Ensures text is visible and not truncated
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Using Column instead of ListView.builder since we are in SingleChildScrollView
          Column(
            children: List.generate(
              timePractice.length,
              (index) {
                return GestureDetector(
                  onTap: () {
                    _choiceTimePractice = index;
                    _goToNextLevel();
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: (index == _choiceTimePractice)
                            ? AppColors.appcolors_blue1
                            : AppColors.appcolors_pinky,
                      ),
                    ),
                    child: Text(
                      timePractice[index].title,
                      style: TextStyle(
                        fontSize: 15,
                        color: (index == _choiceTimePractice)
                            ? AppColors.appcolors_blue1
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Level 4: Select Skills
  Widget _buildLevel5() {
    return SizedBox(
      height: double.infinity,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              ),
              const SizedBox(width: 5),
              const Flexible(
                child: Text('Which skills would you like to focus on?',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    softWrap: true,
                    overflow: TextOverflow.visible),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: List.generate(
              skills.length,
              (index) {
                final isSelected = _selectedSkills.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedSkills.remove(index); // Deselect if selected
                      } else {
                        _selectedSkills.add(index); // Select if not selected
                      }
                    });
                  },
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        // color: (index == _choiceSkill)
                        color: isSelected
                            ? AppColors.appcolors_blue1
                            : AppColors.appcolors_pinky,
                      ),
                    ),
                    child: Text(
                      skills[index].title,
                      style: TextStyle(
                        fontSize: 15,
                        // color: (index == _choiceSkill)
                        color: isSelected
                            ? AppColors.appcolors_blue1
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: ElevatedButton(
                  onPressed: () {
                    _selectedSkills.isNotEmpty ? _goToNextLevel() : null;
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: _selectedSkills.isNotEmpty
                        ? AppColors.appcolors_blue2
                        : Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Level 6: Registration form
  Widget _buildLevel6() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _goBack,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Almost there!',
                      textAlign: TextAlign.start,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Just a bit more info to set up your Number #1 account.',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                // First Name
                TextField(
                  controller: _tfCntrl_firstName,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    _firstName = value;
                    if (_tfem_first_name != null) {
                      setState(() {
                        _tfem_first_name = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'First Name',
                    hintText: 'First Name',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    errorText: _tfem_first_name,
                  ),
                ),
                const SizedBox(height: 20),
                // Last Name
                TextField(
                  controller: _tfCntrl_lastName,
                  keyboardType: TextInputType.text,
                  onChanged: (value) {
                    _lastName = value;
                    if (_tfem_last_name != null) {
                      setState(() {
                        _tfem_last_name = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Last Name',
                    hintText: 'Last Name',
                    hintStyle: TextStyle(color: Colors.grey.withOpacity(0.6)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    errorText: _tfem_last_name,
                  ),
                ),
                const SizedBox(height: 20),
                // Select Age Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                            color: (_tfem_age == null)
                                ? Colors.grey
                                : Colors.red.withOpacity(0.6)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedAgeItem,
                          hint: Text(
                            'Select your age',
                            style:
                                TextStyle(color: Colors.grey.withOpacity(0.6)),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedAgeItem = newValue;
                            });

                            final index = _ageItems.indexOf(newValue!);
                            _ageSelectIndex = index != -1 ? index : null;

                            if (_tfem_age != null) {
                              _tfem_age = null;
                            }
                          },
                          items: _ageItems.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          isExpanded: true,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    if (_tfem_age != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: Text(
                          _tfem_age!,
                          style:
                              TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                // Select Sex Dropdown
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(
                            color: (_tfem_gender == null)
                                ? Colors.grey
                                : Colors.red.withOpacity(0.6)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedGenderItem,
                          hint: Text(
                            'Select your gender',
                            style:
                                TextStyle(color: Colors.grey.withOpacity(0.6)),
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedGenderItem = newValue;
                            });

                            final index = _genderItems.indexOf(newValue!);
                            _genderSelectIndex = index != -1 ? index : null;

                            if (_tfem_gender != null) {
                              _tfem_gender = null;
                            }
                          },
                          items: _genderItems.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          isExpanded: true,
                          style: const TextStyle(
                              fontSize: 16.0, color: Colors.black),
                          icon: const Icon(Icons.arrow_drop_down,
                              color: Colors.grey),
                        ),
                      ),
                    ),
                    if (_tfem_gender != null)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                        child: Text(
                          _tfem_gender!,
                          style:
                              TextStyle(color: Colors.red[700], fontSize: 12),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 80),
                // Signup Button
                ElevatedButton(
                  onPressed: () {
                    bool isValid = _validateAndSubmit();
                    if (isValid) {
                      _animation =
                          Tween<double>(begin: _animatedProgress, end: 1.0)
                              .animate(_controller);
                      _controller.forward(from: 0);
                      Future.delayed(const Duration(milliseconds: 1500), () {
                        setState(() {
                          _showDoneAnimation = true;
                        });
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          Future.delayed(const Duration(milliseconds: 3000),
                              () {
                            Navigator.of(context).pushReplacement(
                              _createRoute(
                                SignUpSignInForm.getUserData(
                                    choiceLanguage: _choiceLanguage,
                                    choiceLanguageLevel: _choiceLanguageLevel,
                                    choiceLanguageReason: _choiceLanguageReason,
                                    choiceTimePractice: _choiceTimePractice,
                                    selectedSkills: _selectedSkills.toString(),
                                    firstName: _firstName,
                                    lastName: _lastName,
                                    selectedAgeItem: _ageSelectIndex,
                                    selectedGenderItem: _genderSelectIndex),
                              ),
                            );
                          });
                          setState(() {
                            _showLottieText = true;
                          });
                        });
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: AppColors.appcolors_blue2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                  ),
                  child: const Text(
                    'Go to Number #1',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows for more content to be displayed
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: SizedBox(
            height: 500,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // const Center(
                  //   child: SizedBox(
                  //     width: 50,
                  //     height: 5,
                  //     child: Divider(
                  //       thickness: 2,
                  //       color: Colors.black87,
                  //     ),
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  Column(
                    children: List.generate(levels.length, (index) {
                      return Column(
                        children: [
                          getLanLevelContainer(
                              levels[index].title,
                              otherLevelsData[index].level,
                              '',
                              'This is the first step in learning a new language. You learn basic words, phrases, and sentences. It\'s like learning to crawl before you walk.'),
                          const SizedBox(height: 20),
                        ],
                      );
                    }),
                  ),
                  // getLanLevelContainer(
                  //     levels[0].title,
                  //     otherLevelsData[0].level,
                  //     '',
                  //     'This is the first step in learning a new language. You learn basic words, phrases, and sentences. It\'s like learning to crawl before you walk.'),
                  // const SizedBox(height: 20),
                  // Divider(color: Colors.grey.withOpacity(0.8), height: 1),
                  // const SizedBox(height: 20),
                  // getLanLevelContainer(languageLevels[1], 'B1', '',
                  //     'You\'ve learned the basics and can handle simple conversations and common phrases. It\'s like learning to walk steadily on your own but still needing guidance for longer distances.'),
                  // const SizedBox(height: 20),
                  // Divider(color: Colors.grey.withOpacity(0.8), height: 1),
                  // const SizedBox(height: 20),
                  // getLanLevelContainer(languageLevels[2], 'B2', '',
                  //     'You have mastered the basic and can form simple sentences. It\'s like riding a bike with training wheels.'),
                  // const SizedBox(height: 20),
                  // Divider(color: Colors.grey.withOpacity(0.8), height: 1),
                  // const SizedBox(height: 20),
                  // getLanLevelContainer(languageLevels[3], 'C1', 'C2',
                  //     'You can fluently speak, write, and understand the language. You can ride bike without training wheels and perform special tricks.'),
                  // const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget getLanLevelContainer(String title, a1, a2, str) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        // Subtitle
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.appcolors_pinky,
              ),
              child: Text(
                a1,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (a2 != '')
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.appcolors_pinky,
                ),
                child: Text(
                  a2,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        Text(
          str,
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Define forward animation (right to left)
        const beginForward = Offset(1.0, 0.0); // From right to left
        const end = Offset.zero;

        // Define reverse animation (left to right)
        const beginBackward = Offset(-1.0, 0.0); // From left to right

        const curve = Curves.easeInOut;

        // Check if the animation is going forward or backward
        var tween = animation.status == AnimationStatus.reverse
            ? Tween(begin: beginBackward, end: end)
            : Tween(begin: beginForward, end: end);

        var curvedAnimation = CurvedAnimation(parent: animation, curve: curve);

        return SlideTransition(
          position: tween.animate(curvedAnimation),
          child: child,
        );
      },
    );
  }
}
