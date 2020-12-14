// Copyright 2020 Kuei-chun Chen. All rights reserved.
// MySQLConn.java

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;
import java.util.Arrays;

/**
 * Usage: MySQLConn uri user password
 */
class MySQLConn {
    public static void main(String []args) {
        String uri = System.getenv("bi_uri");
        String user = System.getenv("bi_user");
        String password = System.getenv("bi_password");

        if (args.length > 2) {
            uri = args[0];
            user = args[1];
            password = args[2];
        }

        try {
            String []protocols = javax.net.ssl.SSLContext.getDefault().getSupportedSSLParameters().getProtocols();
            System.out.println(Arrays.toString(protocols));
            Connection conn = DriverManager.getConnection(uri, user, password);
            Statement stmt = conn.createStatement();
            System.out.println("Connected!");
            stmt.close();
            conn.close();
        } catch (Exception e) {
            e.printStackTrace();
            System.exit(-1);
        }
    }
}
