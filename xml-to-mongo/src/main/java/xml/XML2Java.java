package xml;

import static org.bson.codecs.configuration.CodecRegistries.fromProviders;
import static org.bson.codecs.configuration.CodecRegistries.fromRegistries;

import java.io.File;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBException;
import javax.xml.bind.Unmarshaller;

import org.bson.codecs.configuration.CodecRegistry;
import org.bson.codecs.pojo.PojoCodecProvider;

import com.mongodb.MongoClient;
import com.mongodb.MongoClientURI;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

public class XML2Java {
	public static void main(String[] args) {

	 try {
		File file = new File("src/main/java/xml/hello.xml");
		JAXBContext jaxbContext = JAXBContext.newInstance(Customer.class);
		Unmarshaller jaxbUnmarshaller = jaxbContext.createUnmarshaller();
		Customer customer = (Customer) jaxbUnmarshaller.unmarshal(file);

		CodecRegistry pojoCodecRegistry = fromRegistries(MongoClient.getDefaultCodecRegistry(),
                fromProviders(PojoCodecProvider.builder().automatic(true).build()));
		MongoClient client = new MongoClient(new MongoClientURI("mongodb://localhost/test"));
		MongoDatabase database = client.getDatabase("test");
		database = database.withCodecRegistry(pojoCodecRegistry);
		MongoCollection<Customer> coll = database.getCollection("xml", Customer.class);
		coll.withCodecRegistry(pojoCodecRegistry); 
		coll.insertOne(customer);
		client.close();
	  } catch (JAXBException e) {
		e.printStackTrace();
	  }
	}
}
