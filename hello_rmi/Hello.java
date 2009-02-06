import java.rmi.*;
import java.rmi.server.*;
/**
 * Remote Class for the "Hello, world!" example.
 */
public class Hello extends UnicastRemoteObject implements HelloInterface {
  private String name; 
  private int cacheSize = DEFAULT_CACHE_SIZE; 
  private static final int DEFAULT_CACHE_SIZE = 200; 

  public Hello (String newname) throws RemoteException {
    this.name = newname;
  }

  public String say() throws RemoteException {
    return "Hello, " + this.name + "!";
  }

  public void sayPrint() throws RemoteException {
    System.out.println(this.say());
  }

  public int add(int x, int y) throws RemoteException {
    return x + y;
  }

  public String getName() throws RemoteException {
    return this.name;
  }

  public int getCacheSize() throws RemoteException {
    return this.cacheSize;
  }

  public synchronized void setCacheSize(int size) throws RemoteException {
    this.cacheSize = size;
    System.out.println("Cache size now " + this.cacheSize);
  }
}
