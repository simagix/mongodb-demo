package dealer;

import java.util.List;

import org.springframework.data.domain.Pageable;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.data.mongodb.repository.Query;

public interface VehicleRepository extends MongoRepository<Vehicle, String> {

    public List<Vehicle> findByColor(String color);
    public List<Vehicle> findByStyle(String style);
    public List<Vehicle> findByColorAndStyle(String color, String style);
    
    @Query("{ color : 'Red', style: 'Truck' }")
    public List<Vehicle> findRedTrucks(Pageable pageable);
    
    @Query("{ color : 'Red', used: false }")
    public List<Vehicle> findNewRedVehicle(Pageable pageable);

}
