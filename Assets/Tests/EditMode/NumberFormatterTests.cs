using NUnit.Framework;
using DokkaebiHand.Core;

namespace DokkaebiHand.Tests
{
    [TestFixture]
    public class NumberFormatterTests
    {
        [Test]
        public void Small_Numbers_Not_Abbreviated()
        {
            Assert.AreEqual("350", NumberFormatter.FormatScore(350));
            Assert.AreEqual("1,440", NumberFormatter.FormatScore(1440));
            Assert.AreEqual("9,999", NumberFormatter.FormatScore(9999));
        }

        [Test]
        public void Thousands_Use_K()
        {
            Assert.AreEqual("42K", NumberFormatter.Format(42000));
            Assert.AreEqual("100K", NumberFormatter.Format(100000));
            Assert.AreEqual("999K", NumberFormatter.Format(999000));
        }

        [Test]
        public void Millions_Use_M()
        {
            Assert.AreEqual("1.23M", NumberFormatter.Format(1234567));
            Assert.AreEqual("42.5M", NumberFormatter.Format(42500000));
        }

        [Test]
        public void Billions_Use_B()
        {
            Assert.AreEqual("1.23B", NumberFormatter.Format(1234567890));
        }

        [Test]
        public void FormatMult_Small()
        {
            Assert.AreEqual("×3", NumberFormatter.FormatMult(3));
            Assert.AreEqual("×120", NumberFormatter.FormatMult(120));
        }

        [Test]
        public void FormatMult_Large()
        {
            Assert.AreEqual("×42K", NumberFormatter.FormatMult(42000));
        }

        [Test]
        public void FormatScientific()
        {
            Assert.AreEqual("1.23e4", NumberFormatter.FormatScientific(12345));
            Assert.AreEqual("1.00e6", NumberFormatter.FormatScientific(1000000));
        }

        [Test]
        public void FormatScore_Under_100K_Shows_Full()
        {
            Assert.AreEqual("99,999", NumberFormatter.FormatScore(99999));
        }

        [Test]
        public void FormatScore_Over_100K_Abbreviates()
        {
            Assert.AreEqual("150K", NumberFormatter.FormatScore(150000));
        }
    }
}
