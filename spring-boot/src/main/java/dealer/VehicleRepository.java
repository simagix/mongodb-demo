package dealer;

import java.util.List;

import org.springframework.data.mongodb.repository.MongoRepository;

public interface VehicleRepository extends MongoRepository<Vehicle, String> {

    public List<Vehicle> findByColor(String color);
    public List<Vehicle> findByStyle(String style);
    public List<Vehicle> findByColorAndStyle(String color, String style);

}
