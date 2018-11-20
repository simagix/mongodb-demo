package dealer;

import static org.springframework.data.mongodb.core.query.Criteria.where;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.data.mongodb.MongoDbFactory;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.convert.DefaultDbRefResolver;
import org.springframework.data.mongodb.core.convert.DefaultMongoTypeMapper;
import org.springframework.data.mongodb.core.convert.MappingMongoConverter;
import org.springframework.data.mongodb.core.mapping.MongoMappingContext;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;

@SpringBootApplication
public class Application implements CommandLineRunner {
	Logger logger = LoggerFactory.getLogger(Application.class);
	
	@Autowired
	private VehicleRepository repository;
	
	@Autowired
	private MongoTemplate templ;

	public static void main(String[] args) {
		SpringApplication.run(Application.class, args);
	}
	
	@Bean
    public MongoTemplate mongoTemplate(MongoDbFactory mongoDbFactory,
                                       MongoMappingContext context) {
        MappingMongoConverter converter =
                new MappingMongoConverter(new DefaultDbRefResolver(mongoDbFactory), context);
        converter.setTypeMapper(new DefaultMongoTypeMapper(null));
        MongoTemplate mongoTemplate = new MongoTemplate(mongoDbFactory, converter);
        return mongoTemplate;
    }

	@Override
	public void run(String... args) throws Exception {
		logger.info("Use database "  + templ.getDb().getName());
		logger.info("Collection exists? " + templ.collectionExists(Vehicle.class));
		logger.info("Total # of vehicles: " + repository.count());
		
		// use CustomerRepository
		logger.info("Total # of red vehicles: " + repository.findByColor("Red").size());
		// use spring mongo driver
		logger.info("Total # of red vehicles: " + templ.find(new Query(where("color").is("Red")), Vehicle.class).size());

		// use CustomerRepository
		logger.info("Total # of red trucks: " + repository.findByColorAndStyle("Red", "Truck").size());
		// use spring mongo driver
		Criteria criteria = new Criteria();
        criteria.andOperator(Criteria.where("color").is("Red"),Criteria.where("style").is("Truck"));
		logger.info("Total # of red trucks: " + templ.find(new Query(criteria), Vehicle.class).size());
	}
}
