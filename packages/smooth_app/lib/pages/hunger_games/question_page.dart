import 'package:flutter/material.dart';
import 'package:matomo_tracker/matomo_tracker.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:provider/provider.dart';
import 'package:smooth_app/background/background_task_hunger_games.dart';
import 'package:smooth_app/database/local_database.dart';
import 'package:smooth_app/generic_lib/design_constants.dart';
import 'package:smooth_app/generic_lib/duration_constants.dart';
import 'package:smooth_app/pages/hunger_games/congrats.dart';
import 'package:smooth_app/pages/hunger_games/question_answers_options.dart';
import 'package:smooth_app/pages/hunger_games/question_card.dart';
import 'package:smooth_app/query/product_questions_query.dart';
import 'package:smooth_app/query/questions_query.dart';
import 'package:smooth_app/query/random_questions_query.dart';
import 'package:smooth_app/widgets/smooth_scaffold.dart';

class QuestionPage extends StatefulWidget {
  const QuestionPage({
    this.product,
    this.questions,
    this.updateProductUponAnswers,
  });

  final Product? product;
  final List<RobotoffQuestion>? questions;
  final Function()? updateProductUponAnswers;
  bool get shouldDisplayContinueButton => product == null;

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with SingleTickerProviderStateMixin, TraceableClientMixin {
  final Map<String, InsightAnnotation> _anonymousAnnotationList =
      <String, InsightAnnotation>{};
  InsightAnnotation? _lastAnswer;

  late Future<List<RobotoffQuestion>> _questions;
  late final QuestionsQuery _questionsQuery;
  late final LocalDatabase _localDatabase;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();

    _localDatabase = context.read<LocalDatabase>();
    _questionsQuery = widget.product != null
        ? ProductQuestionsQuery(widget.product!.barcode!)
        : RandomQuestionsQuery();

    final List<RobotoffQuestion>? widgetQuestions = widget.questions;

    if (widgetQuestions != null) {
      _questions = Future<List<RobotoffQuestion>>.value(widgetQuestions);
    } else {
      _questions = _questionsQuery.getQuestions(_localDatabase);
    }
  }

  void _reloadQuestions() {
    setState(() {
      _questions = _questionsQuery.getQuestions(_localDatabase);
      _currentQuestionIndex = 0;
    });
  }

  @override
  String get traceTitle => 'robotoff_question_page';

  @override
  String get traceName => 'Opened robotoff_question_page';

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          final Function()? callback = widget.updateProductUponAnswers;
          if (_lastAnswer != null && callback != null) {
            await callback();
          }
          return true;
        },
        child: SmoothScaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(),
          body: _buildAnimationSwitcher(),
        ),
      );

  AnimatedSwitcher _buildAnimationSwitcher() => AnimatedSwitcher(
        duration: SmoothAnimationsDuration.medium,
        transitionBuilder: (Widget child, Animation<double> animation) {
          final Offset animationStartOffset = _getAnimationStartOffset();
          final Animation<Offset> inAnimation = Tween<Offset>(
            begin: animationStartOffset,
            end: Offset.zero,
          ).animate(animation);
          final Animation<Offset> outAnimation = Tween<Offset>(
            begin: animationStartOffset.scale(-1, -1),
            end: Offset.zero,
          ).animate(animation);

          if (child.key == ValueKey<int>(_currentQuestionIndex)) {
            // Animate in the new question card.
            return ClipRect(
              child: SlideTransition(
                position: inAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: child,
                ),
              ),
            );
          } else {
            // Animate out the old question card.
            return ClipRect(
              child: SlideTransition(
                position: outAnimation,
                child: Padding(
                  padding: const EdgeInsets.all(SMALL_SPACE),
                  child: child,
                ),
              ),
            );
          }
        },
        child: Container(
          key: ValueKey<int>(_currentQuestionIndex),
          child: FutureBuilder<List<RobotoffQuestion>>(
            future: _questions,
            builder: (
              BuildContext context,
              AsyncSnapshot<List<RobotoffQuestion>> snapshot,
            ) =>
                snapshot.hasData
                    ? _buildWidget(
                        context,
                        questions: snapshot.data!,
                        questionIndex: _currentQuestionIndex,
                      )
                    : const Center(child: CircularProgressIndicator()),
          ),
        ),
      );

  Offset _getAnimationStartOffset() {
    switch (_lastAnswer) {
      case InsightAnnotation.YES:
        // For [InsightAnnotation.YES]: Animation starts from left side and goes right.
        return const Offset(-1.0, 0);
      case InsightAnnotation.NO:
        // For [InsightAnnotation.NO]: Animation starts from right side and goes left.
        return const Offset(1.0, 0);
      case InsightAnnotation.MAYBE:
      case null:
        // For [InsightAnnotation.MAYBE]: Animation starts from bottom and goes up.
        return const Offset(0, 1);
    }
  }

  Widget _buildWidget(
    BuildContext context, {
    required List<RobotoffQuestion> questions,
    required int questionIndex,
  }) {
    if (questions.length == questionIndex) {
      return CongratsWidget(
        shouldDisplayContinueButton: widget.shouldDisplayContinueButton,
        anonymousAnnotationList: _anonymousAnnotationList,
        onContinue: _reloadQuestions,
      );
    }

    final RobotoffQuestion question = questions[questionIndex];

    return Column(
      children: <Widget>[
        QuestionCard(
          question,
          initialProduct: widget.product,
        ),
        QuestionAnswersOptions(
          question,
          onAnswer: (InsightAnnotation answer) async {
            await _saveAnswer(question, answer);
            setState(() {
              _lastAnswer = answer;
              _currentQuestionIndex++;
            });
          },
        ),
      ],
    );
  }

  Future<void> _saveAnswer(
    final RobotoffQuestion question,
    final InsightAnnotation insightAnnotation,
  ) async {
    final String? barcode = question.barcode;
    final String? insightId = question.insightId;
    if (barcode == null || insightId == null) {
      return;
    }
    if (OpenFoodAPIConfiguration.globalUser == null) {
      _anonymousAnnotationList.putIfAbsent(insightId, () => insightAnnotation);
    }
    await BackgroundTaskHungerGames.addTask(
      barcode: barcode,
      insightId: insightId,
      insightAnnotation: insightAnnotation,
      widget: this,
    );
  }
}
