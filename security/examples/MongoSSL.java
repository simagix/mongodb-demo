package ssl;

import com.mongodb.Block;
import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.MongoIterable;

public class MongoSSL {

	public void connect() {
		String [] hosts = {"ip-172-31-1-1.ec2.internal", "ip-172-31-2-2.ec2.internal", "ip-172-31-3-3.ec2.internal"};
		String url = "mongodb://mongoadm:happy123@" + String.join(",", hosts) + "/admin?authSource=admin&ssl=true&replicaSet=rs-dev";
		System.setProperty("javax.net.ssl.trustStore", "/Users/kenchen/ssl/mongodb.pkcs12");
		System.setProperty("javax.net.ssl.trustStorePassword", "happy123");
		MongoClient client = new MongoClient(new MongoClientURI(url));
		MongoIterable<String> listDatabaseNames = client.listDatabaseNames();
		Block<String> printer = System.out::println;
		listDatabaseNames.forEach(printer);
		
		MongoDatabase database = client.getDatabase("test");
        MongoIterable <String> collections = database.listCollectionNames();
        for (String collectionName: collections) {
            System.out.println(collectionName);
        }
        
		client.close();
	}

	public static void main(String[] args) {
		MongoSSL mssl = new MongoSSL();
		mssl.connect();

	}
}
