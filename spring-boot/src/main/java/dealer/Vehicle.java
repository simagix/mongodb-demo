package dealer;

import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

@Document(collection = "cars")
public class Vehicle {

    @Id
    public String id;

    public String color;
    public String style;
    public boolean isNew;

    public Vehicle() {}

    public Vehicle(String color, String style, boolean isNew) {
        this.color = color;
        this.style = style;
        this.isNew = isNew;
    }

    @Override
    public String toString() {
        return String.format(
                "Vehicle[id=%s, color='%s', style='%s', isNew='%b']",
                id, color, style, isNew);
    }
}
