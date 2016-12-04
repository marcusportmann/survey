/*
 * Copyright 2016 Marcus Portmann
 * All rights reserved.
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package digital.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.databind.ObjectMapper;
import guru.mmp.application.security.Organisation;

import javax.enterprise.inject.Vetoed;
import javax.persistence.*;
import java.io.*;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyDefinition</code> class implements the Survey Definition entity, which represents
 * a version of a definition for a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@IdClass(VersionedId.class)
@Table(schema = "SURVEY", name = "SURVEY_DEFINITIONS")
@Access(AccessType.FIELD)
@JsonPropertyOrder({ "id", "version", "organisationId", "name", "description", "groupDefinitions",
    "itemDefinitions" })
@Vetoed
public class SurveyDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to, along with the version of the survey
   * definition, uniquely identify the survey definition.
   */
  @Id
  @JsonProperty
  private UUID id;

  /**
   * The version of the survey definition
   */
  @Id
  @JsonProperty
  private int version;

  /**
   * The name of the survey definition.
   */
  @Column(name = "NAME", nullable = false)
  @JsonProperty
  private String name;

  /**
   * The description for the survey definition.
   */
  @Column(name = "DESCRIPTION", nullable = false)
  @JsonProperty
  private String description;

  /**
   * The survey group definitions that are associated with the survey definition.
   */
  @JsonProperty
  @Transient
  private List<SurveyGroupDefinition> groupDefinitions;

  /**
   * The survey item definitions that are associated with the survey definition.
   */
  @JsonProperty
  @Transient
  private List<SurveyItemDefinition> itemDefinitions;

  /**
   * The organisation this survey definition is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "ORGANISATION_ID", referencedColumnName = "ID")
  @JsonIgnore
  protected Organisation organisation;

  /**
   * Is the survey definition anonymous?
   */
  @Column(name = "ANONYMOUS", nullable = false)
  @JsonIgnore
  private boolean isAnonymous;

  /**
   * Constructs a new <code>SurveyDefinition</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyDefinition() {}

  /**
   * Constructs a new <code>SurveyDefinition</code>.
   *
   * @param id           the Universally Unique Identifier (UUID) used to, along with the version
   *                     of the survey definition, uniquely identify the survey definition
   * @param version      the version of the survey definition
   * @param organisation the organisation this survey definition is associated with
   * @param name         the name of the survey definition
   * @param description  the description for the survey definition
   */
  public SurveyDefinition(UUID id, int version, Organisation organisation, String name,
      String description)
  {
    this.id = id;
    this.version = version;
    this.organisation = organisation;
    this.name = name;
    this.description = description;
    this.itemDefinitions = new ArrayList<>();
    this.groupDefinitions = new ArrayList<>();
  }

  /**
   * Add the survey group definition to the survey definition.
   *
   * @param groupDefinition the survey group definition
   */
  public void addGroupDefinition(SurveyGroupDefinition groupDefinition)
  {
    groupDefinitions.add(groupDefinition);
  }

  /**
   * Add the survey item definition to the survey definition.
   *
   * @param itemDefinition the survey item definition
   */
  public void addItemDefinition(SurveyItemDefinition itemDefinition)
  {
    itemDefinitions.add(itemDefinition);
  }

  /**
   * Indicates whether some other object is "equal to" this one.
   *
   * @param obj the reference object with which to compare
   *
   * @return <code>true</code> if this object is the same as the obj argument otherwise
   *         <code>false</code>
   */
  @Override
  public boolean equals(Object obj)
  {
    if (this == obj)
    {
      return true;
    }

    if (obj == null)
    {
      return false;
    }

    if (getClass() != obj.getClass())
    {
      return false;
    }

    SurveyDefinition other = (SurveyDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the JSON data for the survey definition.
   *
   * @return the JSON data for the survey definition
   */
  @Column(name = "DATA", nullable = false)
  @Access(AccessType.PROPERTY)
  @JsonIgnore
  public String getData()
  {
    try
    {
      return new ObjectMapper().writeValueAsString(this);
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to generate the JSON data for the survey definition", e);
    }
  }

  /**
   * Returns the description for the survey definition.
   *
   * @return the description for the survey definition
   */
  public String getDescription()
  {
    return description;
  }

  /**
   * Retrieve the survey group definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           group definition
   *
   * @return the survey group definition or <code>null</code> if the survey group definition could
   *         not be found
   */
  public SurveyGroupDefinition getGroupDefinition(UUID id)
  {
    for (SurveyGroupDefinition groupDefinition : groupDefinitions)
    {
      if (groupDefinition.getId().equals(id))
      {
        return groupDefinition;
      }
    }

    return null;
  }

  /**
   * Returns the survey group definitions that are associated with the survey definition.
   *
   * @return the survey group definitions that are associated with the survey definition
   */
  public List<SurveyGroupDefinition> getGroupDefinitions()
  {
    return groupDefinitions;
  }

  /**
   * Retrieve the survey group rating definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating definition
   *
   * @return the survey group rating definition or <code>null</code> if the survey group rating
   *         definition could not be found
   */
  public SurveyGroupRatingDefinition getGroupRatingDefinition(UUID id)
  {
    return SurveyGroupRatingDefinition.getGroupRatingDefinition(itemDefinitions, id);
  }

// TODO: DELETE THIS -- MARCUS
//  /**
//   * Returns the survey group ratings definitions associated with the survey group definition.
//   *
//   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
//   *           group definition
//   *
//   * @return the survey group ratings definitions associated with the survey group definition
//   */
//  public List<SurveyGroupRatingsDefinition> getGroupRatingsDefinitionsForGroupDefinition(UUID id)
//  {
//    List<SurveyGroupRatingsDefinition> matchingGroupRatingsDefinitions = new ArrayList<>();
//
//    for (SurveyItemDefinition itemDefinition : itemDefinitions)
//    {
//      if (itemDefinition instanceof SurveyGroupRatingsDefinition)
//      {
//        SurveyGroupRatingsDefinition groupRatingsDefinition =
//            (SurveyGroupRatingsDefinition) itemDefinition;
//
//        if (groupRatingsDefinition.getGroupDefinitionId().equals(id))
//        {
//          matchingGroupRatingsDefinitions.add(groupRatingsDefinition);
//        }
//      }
//    }
//
//    return matchingGroupRatingsDefinitions;
//  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to, along with the version of the survey
   * definition, uniquely identify the survey definition.
   *
   * @return the Universally Unique Identifier (UUID) used to, along with the version of the survey
   *         definition, uniquely identify the survey definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Retrieve the survey item definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey item
   *           definition
   *
   * @return the survey item definition or <code>null</code> if the survey item definition could not
   *         be found
   */
  public SurveyItemDefinition getItemDefinition(UUID id)
  {
    for (SurveyItemDefinition itemDefinition : itemDefinitions)
    {
      if (itemDefinition.equals(id))
      {
        return itemDefinition;
      }
    }

    return null;
  }

  /**
   * Returns the survey item definitions.
   *
   * @return the survey item definitions
   */
  public List<SurveyItemDefinition> getItemDefinitions()
  {
    return itemDefinitions;
  }

  /**
   * Returns the name of the survey definition.
   *
   * @return the name of the survey definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the organisation this survey definition is associated with.
   *
   * @return the organisation this survey definition is associated with
   */
  public Organisation getOrganisation()
  {
    return organisation;
  }

  /**
   * Returns the version of the survey definition.
   *
   * @return the version of the survey definition
   */
  public int getVersion()
  {
    return version;
  }

  /**
   * Is the survey definition anonymous?
   *
   * @return <code>true</code> if the survey definition is anonymous or <code>false</code> otherwise
   */
  @JsonIgnore
  public boolean isAnonymous()
  {
    return isAnonymous;
  }

  /**
   * Remove the survey group definition from the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           group definition
   */
  public void removeGroupDefinition(UUID id)
  {
    for (SurveyGroupDefinition surveyGroupDefinition : groupDefinitions)
    {
      if (surveyGroupDefinition.getId().equals(id))
      {
        groupDefinitions.remove(surveyGroupDefinition);

        return;
      }
    }
  }

  /**
   * Remove the survey item definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           ratings definition
   */
  public void removeItemDefinition(UUID id)
  {
    for (SurveyItemDefinition itemDefinition : itemDefinitions)
    {
      if (itemDefinition.getId().equals(id))
      {
        itemDefinitions.remove(itemDefinition);

        return;
      }
    }
  }

  /**
   * Set whether the survey definition is anonymous.
   *
   * @param isAnonymous <code>true</code> if the survey definition is anonymous or
   *                    <code>false</code> otherwise
   */
  @JsonIgnore
  public void setAnonymous(boolean isAnonymous)
  {
    this.isAnonymous = isAnonymous;
  }

  /**
   * Set the JSON data for the survey definition.
   *
   * @param data the JSON data for the survey definition
   */
  public void setData(String data)
  {
    try
    {
      new ObjectMapper().readerForUpdating(this).readValue(data);
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to populate the survey definition using the JSON data", e);
    }
  }

  /**
   * Set the description for the survey definition.
   *
   * @param description the description for the survey definition
   */
  public void setDescription(String description)
  {
    this.description = description;
  }

  /**
   * Set the survey group definitions that are associated with the survey definition.
   *
   * @param groupDefinitions the survey group definitions that are associated with the survey
   *                         definition
   */
  public void setGroupDefinitions(List<SurveyGroupDefinition> groupDefinitions)
  {
    this.groupDefinitions = groupDefinitions;
  }

  /**
   * Set the name of the survey definition.
   *
   * @param name the name of the survey definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey definition.
   *
   * @return the String representation of the survey definition
   */
  @Override
  public String toString()
  {
    int count;

    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyDefinition {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("version=\"").append(getVersion()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("description=\"").append(getDescription()).append("\", ");

    buffer.append("groupDefinitions={");

    count = 0;

    for (SurveyGroupDefinition group : groupDefinitions)
    {
      if (count > 0)
      {
        buffer.append(", ");
      }

      buffer.append(group);

      count++;
    }

    buffer.append("}, ");

    buffer.append("itemDefinitions={");

    count = 0;

    for (SurveyItemDefinition itemDefinition : itemDefinitions)
    {
      if (count > 0)
      {
        buffer.append(", ");
      }

      buffer.append(itemDefinition);

      count++;
    }

    buffer.append("}");

    buffer.append("}");

    return buffer.toString();
  }

  /**
   * Duplicate (deep-copy) this survey definition.
   *
   * @return the duplicated (deep-copied) survey definition
   */
  SurveyDefinition duplicate()
  {
    byte[] surveyDefinitionData;

    try (ByteArrayOutputStream baos = new ByteArrayOutputStream();
      ObjectOutputStream oos = new ObjectOutputStream(baos))
    {
      oos.writeObject(this);
      oos.flush();

      surveyDefinitionData = baos.toByteArray();
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to duplicate the survey definition", e);
    }

    try (ByteArrayInputStream bais = new ByteArrayInputStream(surveyDefinitionData);
      ObjectInputStream ois = new ObjectInputStream(bais))
    {
      return (SurveyDefinition) ois.readObject();
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to duplicate the survey definition", e);
    }
  }

  /**
   * Increment the version of the survey definition.
   */
  void incrementVersion()
  {
    version++;
  }
}
