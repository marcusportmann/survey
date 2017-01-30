package digital.survey.model;

import org.postgresql.util.PGobject;

import javax.persistence.AttributeConverter;
import java.sql.SQLException;
import java.util.UUID;

//@javax.persistence.Converter(autoApply = true)
public class UuidConverter implements AttributeConverter<UUID, Object>
{
  @Override
  public Object convertToDatabaseColumn(UUID uuid) {
    PGobject object = new PGobject();
    object.setType("uuid");
    try {
      if (uuid == null) {
        object.setValue(null);
      } else {
        object.setValue(uuid.toString());
      }
    } catch (SQLException e) {
      throw new IllegalArgumentException("Error when creating Postgres uuid", e);
    }
    return object;
  }

  @Override
  public UUID convertToEntityAttribute(Object dbData) {
    return (UUID) dbData;
  }
}
