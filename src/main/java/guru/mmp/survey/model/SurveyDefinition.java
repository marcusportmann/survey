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

package guru.mmp.survey.model;

//~--- non-JDK imports --------------------------------------------------------

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;
import com.fasterxml.jackson.databind.ObjectMapper;

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
@JsonPropertyOrder({ "id", "version", "organisationId", "name", "description", "sectionDefinitions",
    "groupDefinitions", "groupRatingItemDefinitions" })
public class SurveyDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used, along with the version of the survey definition,
   * to uniquely identify the survey definition.
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
   * The Universally Unique Identifier (UUID) used to uniquely identify the organisation the survey
   * definition is associated with.
   */
  @Column(name = "ORGANISATION_ID", nullable = false)
  @JsonProperty
  private UUID organisationId;

  /**
   * The description for the survey definition.
   */
  @Column(name = "DESCRIPTION", nullable = false)
  @JsonProperty
  private String description;

  /**
   * The survey section definitions that are associated with the survey definition.
   */
  @JsonProperty
  @Transient
  private List<SurveySectionDefinition> sectionDefinitions;

  /**
   * The survey group definitions that are associated with the survey definition.
   */
  @JsonProperty
  @Transient
  private List<SurveyGroupDefinition> groupDefinitions;

  /**
   * The survey group rating item definitions that are associated with the survey definition.
   */
  @JsonProperty
  @Transient
  private List<SurveyGroupRatingItemDefinition> groupRatingItemDefinitions;

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
   * @param id             the Universally Unique Identifier (UUID) used, along with the version of
   *                       the survey definition, to uniquely identify the survey definition
   * @param version        the version of the survey definition
   * @param organisationId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       organisation the survey definition is associated with
   * @param name           the name of the survey definition
   * @param description    the description for the survey definition
   */
  public SurveyDefinition(UUID id, int version, UUID organisationId, String name,
      String description)
  {
    this.id = id;
    this.version = version;
    this.organisationId = organisationId;
    this.name = name;
    this.description = description;
    this.sectionDefinitions = new ArrayList<>();
    this.groupDefinitions = new ArrayList<>();
    this.groupRatingItemDefinitions = new ArrayList<>();
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
   * Add the survey group rating item definition to the survey definition.
   *
   * @param groupRatingItemDefinition the survey group rating item definition
   */
  public void addGroupRatingItemDefinition(
      SurveyGroupRatingItemDefinition groupRatingItemDefinition)
  {
    groupRatingItemDefinitions.add(groupRatingItemDefinition);
  }

  /**
   * Add the survey section definition to the survey definition.
   *
   * @param sectionDefinition the survey group definition
   */
  public void addSectionDefinition(SurveySectionDefinition sectionDefinition)
  {
    sectionDefinitions.add(sectionDefinition);
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
   * Retrieve the survey group rating item definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating item definition
   *
   * @return the survey group rating item definition or <code>null</code> if the survey group rating
   *         item definition could not be found
   */
  public SurveyGroupRatingItemDefinition getGroupRatingItemDefinition(UUID id)
  {
    for (SurveyGroupRatingItemDefinition groupRatingItemDefinition : groupRatingItemDefinitions)
    {
      if (groupRatingItemDefinition.getId().equals(id))
      {
        return groupRatingItemDefinition;
      }
    }

    return null;
  }

  /**
   * Returns the survey group rating item definitions that are associated with the survey
   * definition.
   *
   * @return the survey group rating item definitions that are associated with the survey
   *         definition
   */
  public List<SurveyGroupRatingItemDefinition> getGroupRatingItemDefinitions()
  {
    return groupRatingItemDefinitions;
  }

  /**
   * Returns the survey group rating item definitions associated with the survey group definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           group definition
   *
   * @return the survey group rating item definitions associated with the survey group definition
   */
  public List<SurveyGroupRatingItemDefinition> getGroupRatingItemDefinitionsForGroupDefinition(
      UUID id)
  {
    List<SurveyGroupRatingItemDefinition> matchingGroupRatingItemDefinitions = new ArrayList<>();

    for (SurveyGroupRatingItemDefinition groupRatingItemDefinition : groupRatingItemDefinitions)
    {
      if (groupRatingItemDefinition.getGroupDefinitionId().equals(id))
      {
        matchingGroupRatingItemDefinitions.add(groupRatingItemDefinition);
      }
    }

    return matchingGroupRatingItemDefinitions;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used, along with the version of the survey
   * definition, to uniquely identify the survey definition.
   *
   * @return the Universally Unique Identifier (UUID) used, along with the version of the survey
   *         definition, to uniquely identify the survey definition
   */
  public UUID getId()
  {
    return id;
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
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the organisation the
   * survey definition is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the organisation the
   *         survey definition is associated with
   */
  public UUID getOrganisationId()
  {
    return organisationId;
  }

  /**
   * Retrieve the survey section definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey section
   *           definition
   *
   * @return the survey section definition or <code>null</code> if the survey section definition
   *         could not be found
   */
  public SurveySectionDefinition getSectionDefinition(UUID id)
  {
    for (SurveySectionDefinition sectionDefinition : sectionDefinitions)
    {
      if (sectionDefinition.getId().equals(id))
      {
        return sectionDefinition;
      }
    }

    return null;
  }

  /**
   * Returns the survey section definitions that are associated with the survey definition.
   *
   * @return the survey section definitions that are associated with the survey definition
   */
  public List<SurveySectionDefinition> getSectionDefinitions()
  {
    return sectionDefinitions;
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
   * Remove the survey group rating item definition from the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating item definition
   */
  public void removeGroupRatingItemDefinition(UUID id)
  {
    for (SurveyGroupRatingItemDefinition groupRatingItemDefinition : groupRatingItemDefinitions)
    {
      if (groupRatingItemDefinition.getId().equals(id))
      {
        groupRatingItemDefinitions.remove(groupRatingItemDefinition);

        return;
      }
    }
  }

  /**
   * Remove the survey section definition from the survey definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           section definition
   */
  public void removeSectionDefinition(UUID id)
  {
    for (SurveySectionDefinition sectionDefinition : sectionDefinitions)
    {
      if (sectionDefinition.getId().equals(id))
      {
        sectionDefinitions.remove(sectionDefinition);

        return;
      }
    }
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
   * Set the survey group rating item definitions that are associated with the survey definition.
   *
   * @param groupRatingItemDefinitions the survey group rating item definitions that are associated
   *                                   with the survey definition
   */
  public void setGroupRatingItemDefinitions(
      List<SurveyGroupRatingItemDefinition> groupRatingItemDefinitions)
  {
    this.groupRatingItemDefinitions = groupRatingItemDefinitions;
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
   * Set the survey section definitions that are associated with the survey definition.
   *
   * @param sectionDefinitions the survey section definitions that are associated with the survey
   *                           definition
   */
  public void setSectionDefinitions(List<SurveySectionDefinition> sectionDefinitions)
  {
    this.sectionDefinitions = sectionDefinitions;
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

    buffer.append("groupRatingItemDefinitions={");

    count = 0;

    for (SurveyGroupRatingItemDefinition groupRatingItem : groupRatingItemDefinitions)
    {
      if (count > 0)
      {
        buffer.append(", ");
      }

      buffer.append(groupRatingItem);

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
