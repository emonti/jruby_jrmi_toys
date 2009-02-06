
import java.rmi.Naming;

public class HelloServer {
  public static void main (String[] argv) {
    String message = "Hello, World!";
    if (argv.length > 0) {
      message = argv[0];
    }
    try {
      Naming.rebind("Hello", new Hello("ruby! (via RMI)"));
      System.out.println("Hello Server is ready.");
    } catch (Exception e) {
      System.out.println("HelloServer failed: " + e);
    }
  }
}
