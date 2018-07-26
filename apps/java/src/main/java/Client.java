import static com.mongodb.client.model.Filters.eq;

import java.util.logging.Level;
import java.util.logging.Logger;

import org.bson.Document;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;

public class Client {
	public void connect() {
        String [] hosts = {"localhost"};
        String url = "mongodb://user:password@" + String.join(",", hosts) + "/keyhole?authSource=admin&ssl=true";
        
        System.setProperty("javax.net.ssl.keyStore", "/etc/ssl/certs/keystore.jks");
        System.setProperty("javax.net.ssl.keyStorePassword", "password");
        System.setProperty("javax.net.ssl.keyStoreType", "JKS");
        
        System.setProperty("javax.net.ssl.trustStore", "/etc/ssl/certs/truststore.jks");
        System.setProperty("javax.net.ssl.trustStorePassword", "password");
        System.setProperty("javax.net.ssl.trustStoreType", "JKS");

        MongoClient client = new MongoClient(new MongoClientURI(url));
        MongoCollection<Document> collection = client.getDatabase("keyhole").getCollection("cars");

        long count = collection.count(eq("color", "Red"));
        System.out.println("number of red cars: " + count);
        client.close();
	}

	public static void main(String[] args) {
		Logger mongoLogger = Logger.getLogger( "org.mongodb.driver" );
		mongoLogger.setLevel(Level.SEVERE);
        Client client = new Client();
        client.connect();
	}
}
