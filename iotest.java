import java.io.*;
import java.sql.*;
import java.text.*;
import oracle.jdbc.*;
 
class MultithreadingDemo implements Runnable{
  private String table_number;
  Connection conn;
 
  MultithreadingDemo(String name) {
    table_number = name;
 
        try {
           DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
           conn = DriverManager.getConnection( "jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=172.....)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=IOTEST)))", "io_test", "io_test" );
           System.out.println("Thread:" + table_number + " - connection established.");
        } catch (SQLException e) {
           System.err.println(e.getMessage());
           e.printStackTrace();
        }
  }
 
  public void run(){
    CallableStatement cstmt;
 
    System.out.println("Thread:" + table_number + " is in running state.");
 
    while(true) {
      try {
        cstmt = conn.prepareCall("{CALL io_test(?)}");
        cstmt.setString(1, table_number);
        cstmt.executeUpdate();
        cstmt.close();
        Thread.sleep(1000);
      } catch (SQLException e) {
        System.out.println("SQL Exception in thread:" + table_number);
                   System.out.println ("\n*** Java Stack Trace ***\n");
                   e.printStackTrace();          
                   System.out.println ("\n*** SQLException caught ***\n"); 
        while(true){
           try {
              Thread.sleep(1000);
              DriverManager.registerDriver(new oracle.jdbc.driver.OracleDriver());
              conn = DriverManager.getConnection( "jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=172.....)(PORT=1521))(CONNECT_DATA=(SERVER=DEDICATED)(SERVICE_NAME=IOTEST)))", "io_test", "io_test" );
              System.out.println("Thread:" + table_number + " - connection re-established.");
              break;
           } catch (SQLException e1) {
              System.err.println(e1.getMessage());
              e1.printStackTrace();
           }
            catch (Exception e2) {
              System.err.println(e2.getMessage());
              e2.printStackTrace();
           }
        }


      } catch (InterruptedException e) {
        System.out.println("Thread has been interrupted");
        return;
      }
    }
  }
  public static void main(String args[]){
     int i;
     int s_pos;
     int e_pos;
         
     MultithreadingDemo obj100[]=new MultithreadingDemo[700];
     Thread tobj100[]= new Thread[700];
 
     if ( args.length!=2 ) {
            System.out.println("Invalid number of arguments.");
                        return;
     }

        try {
           s_pos = Integer.parseInt(args[0]);
        }
        catch (NumberFormatException e)
        {
           System.out.println("Wrong argument type.");
           return;
        }

        try {
           e_pos = Integer.parseInt(args[1]);
        }
        catch (NumberFormatException e)
        {
           System.out.println("Wrong argument type.");
           return;
        }
                
     for( i=s_pos; i<=e_pos; i++ ){
        obj100[i-1] = new MultithreadingDemo(Integer.toString(i));
        tobj100[i-1] = new Thread(obj100[i-1]);
     }
     for( i=s_pos; i<=e_pos; i++ ){
        tobj100[i-1].start();
     }
  }
}


cd /u01/oracle/oracle_tr/ACS_tests
CLASSPATH=.:$ORACLE_HOME/jdbc/lib/ojdbc5.jar
export CLASSPATH

/u01/app/oracle/product/11.2.0/dbhome_1/jdk/bin/java MultithreadingDemo 1 450 &
/u01/app/oracle/product/11.2.0/dbhome_1/jdk/bin/java MultithreadingDemo 1 450 &
/u01/app/oracle/product/11.2.0/dbhome_1/jdk/bin/java MultithreadingDemo 1 450 &
/u01/app/oracle/product/11.2.0/dbhome_1/jdk/bin/java MultithreadingDemo 1 450 &
/u01/app/oracle/product/11.2.0/dbhome_1/jdk/bin/java MultithreadingDemo 1 450 &
    <>enc(s33c+AHwXVWw9Fjr7FuMcg==)</Password>


cd /d "C:\YKB\dbtimemonitor\bin"
"C:\Program Files\Java\jre1.8.0_231\bin\java" -cp ../launcher LauncherBootstrap -executablename waitmonitor waitmonitor %1 %2 %3 %4 %5 %6 %7 %8
