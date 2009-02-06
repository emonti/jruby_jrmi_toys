import java.rmi.Naming;
/**
* Client program for the "Hello, world!" example.
* @param argv The command line arguments which are ignored.
*/
public class HelloClient {
  public static void main (String[] argv) {
    String rmiurl = "//localhost:1099/Hello";
    if (argv.length > 0)
    {
      rmiurl = argv[0];
    }
    try {
      HelloInterface hello = (HelloInterface) Naming.lookup (rmiurl);
      System.out.println (hello.say());
    } catch (Exception e) {
      System.out.println ("HelloClient exception: " + e);
    }
  }
}
