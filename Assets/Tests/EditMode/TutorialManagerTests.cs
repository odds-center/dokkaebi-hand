using NUnit.Framework;
using DokkaebiHand.Core;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class TutorialManagerTests
    {
        private TutorialManager _tutorial;

        [SetUp]
        public void SetUp()
        {
            _tutorial = new TutorialManager();
        }

        [Test]
        public void InitialState_IsNotStarted()
        {
            Assert.AreEqual(TutorialManager.TutorialStep.NotStarted, _tutorial.CurrentStep);
            Assert.IsFalse(_tutorial.IsActive);
        }

        [Test]
        public void Start_Sets_Step1()
        {
            _tutorial.Start();
            Assert.AreEqual(TutorialManager.TutorialStep.Step1_Matching, _tutorial.CurrentStep);
            Assert.IsTrue(_tutorial.IsActive);
        }

        [Test]
        public void AdvanceStep_Progresses_Through_All_Steps()
        {
            _tutorial.Start();

            _tutorial.AdvanceStep();
            Assert.AreEqual(TutorialManager.TutorialStep.Step2_Yokbo, _tutorial.CurrentStep);

            _tutorial.AdvanceStep();
            Assert.AreEqual(TutorialManager.TutorialStep.Step3_GoStop, _tutorial.CurrentStep);

            _tutorial.AdvanceStep();
            Assert.AreEqual(TutorialManager.TutorialStep.Step4_Strategy, _tutorial.CurrentStep);

            _tutorial.AdvanceStep();
            Assert.AreEqual(TutorialManager.TutorialStep.Complete, _tutorial.CurrentStep);
            Assert.IsFalse(_tutorial.IsActive);
        }

        [Test]
        public void Skip_Completes_Immediately()
        {
            _tutorial.Start();
            Assert.IsTrue(_tutorial.IsActive);

            _tutorial.Skip();
            Assert.AreEqual(TutorialManager.TutorialStep.Complete, _tutorial.CurrentStep);
            Assert.IsFalse(_tutorial.IsActive);
        }

        [Test]
        public void AdvanceStep_After_Complete_Stays_Complete()
        {
            _tutorial.Start();
            _tutorial.Skip();
            _tutorial.AdvanceStep();
            Assert.AreEqual(TutorialManager.TutorialStep.Complete, _tutorial.CurrentStep);
        }

        [Test]
        public void Each_Step_Has_Dialogue_And_Hint()
        {
            _tutorial.Start();

            Assert.IsNotNull(_tutorial.CurrentDialogue);
            Assert.IsNotNull(_tutorial.CurrentHint);
            Assert.AreEqual("tutorial_step1_dialogue", _tutorial.CurrentDialogue);

            _tutorial.AdvanceStep();
            Assert.AreEqual("tutorial_step2_dialogue", _tutorial.CurrentDialogue);

            _tutorial.AdvanceStep();
            Assert.AreEqual("tutorial_step3_dialogue", _tutorial.CurrentDialogue);

            _tutorial.AdvanceStep();
            Assert.AreEqual("tutorial_step4_dialogue", _tutorial.CurrentDialogue);
        }

        [Test]
        public void GetPreset_Returns_Valid_Preset()
        {
            var preset = TutorialManager.GetPreset(TutorialManager.TutorialStep.Step1_Matching);
            Assert.IsNotNull(preset);
            Assert.Greater(preset.TargetScore, 0);
        }

        [Test]
        public void OnStepChanged_Event_Fires()
        {
            bool fired = false;
            _tutorial.OnStepChanged += step => fired = true;
            _tutorial.Start();
            _tutorial.AdvanceStep();
            Assert.IsTrue(fired);
        }
    }
}
