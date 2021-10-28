using Microsoft.VisualStudio.TestTools.UnitTesting;
using WebApplicationDGP;

namespace TestProject2
{
    [TestClass]
    public class UnitTest1
    {
        [TestMethod]
        public void TestMethod1()
        {
            clasequevoyatestear test1 = new clasequevoyatestear();
            Assert.IsTrue(test1.method(false));
        }
        [TestMethod]
        public void TestMethod2()
        {
            clasequevoyatestear test2 = new clasequevoyatestear();
            Assert.AreEqual(8, test2.method(4, 4));
        }
    }
}
