using Microsoft.VisualStudio.TestTools.UnitTesting;
using WebApplicationDGP;

namespace TestFuncionales
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
            Assert.AreEqual(6, test2.method(3, 3));
        }
    }
}
