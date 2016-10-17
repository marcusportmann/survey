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

//~--- JDK imports ------------------------------------------------------------

import javax.persistence.*;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

/**
 * The <code>SurveyGroupDefinition</code> class implements the Survey Group Definition entity, which
 * represents a version of a definition of a group of entities, e.g. a team, that are associated
 * with a survey definition.
 *
 * @author Marcus Portmann
 */
@Entity
@IdClass(VersionedId.class)
@Table(schema = "SURVEY", name = "SURVEY_GROUP_DEFINITIONS")
public class SurveyGroupDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used, along with the version of the survey group
   * definition, to uniquely identify the survey group definition.
   */
  @Id
  private UUID id;

  /**
   * The version of the survey group definition.
   */
  @Id
  private int version;

  /**
   * The name of the survey group definition.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The description for the survey group definition.
   */
  @Column(name = "DESCRIPTION", nullable = false)
  private String description;

  /**
   * The survey definition this survey group definition is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumns({ @JoinColumn(name = "SURVEY_DEFINITION_ID", referencedColumnName = "ID") ,
      @JoinColumn(name = "SURVEY_DEFINITION_VERSION", referencedColumnName = "VERSION") })
  private SurveyDefinition surveyDefinition;

  /**
   * The survey group member definitions associated with the survey group definition.
   */
  @OneToMany(mappedBy = "surveyGroupDefinition", cascade = CascadeType.ALL, fetch = FetchType.EAGER,
      orphanRemoval = true)
  @OrderBy("NAME ASC")
  private List<SurveyGroupMemberDefinition> surveyGroupMemberDefinitions;

  /**
   * Constructs a new <code>SurveyDefinitionGroup</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyGroupDefinition() {}

  /**
   * Constructs a new <code>SurveyDefinitionGroup</code>.
   *
   * @param id          the Universally Unique Identifier (UUID) used, along with the version of the
   *                    survey group definition, to uniquely identify the survey group definition
   * @param version     the version of the survey group definition
   * @param name        the name of the survey group definition
   * @param description the description for the survey group definition
   */
  public SurveyGroupDefinition(UUID id, int version, String name, String description)
  {
    this.id = id;
    this.version = version;
    this.name = name;
    this.description = description;
    this.surveyGroupMemberDefinitions = new ArrayList<>();
  }

  /**
   * Add the survey group member definition to the survey group definition.
   *
   * @param surveyGroupMemberDefinition the survey group member definition
   */
  public void addSurveyGroupMemberDefinition(
      SurveyGroupMemberDefinition surveyGroupMemberDefinition)
  {
    surveyGroupMemberDefinition.setGroup(this);

    surveyGroupMemberDefinitions.add(surveyGroupMemberDefinition);
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

    SurveyGroupDefinition other = (SurveyGroupDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the description for the survey group definition.
   *
   * @return the description for the survey group definition
   */
  public String getDescription()
  {
    return description;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used, along with the version of the survey
   * group definition, to uniquely identify the survey group definition.
   *
   * @return the Universally Unique Identifier (UUID) used, along with the version of the survey
   *         group definition, to uniquely identify the survey group definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey group definition.
   *
   * @return the name of the survey group definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Retrieve the survey group member definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           group member definition
   *
   * @return the survey group member definition or <code>null</code> if the survey group member
   *         definition could not be found
   */
  public SurveyGroupMemberDefinition getSurveyGroupMemberDefinition(UUID id)
  {
    for (SurveyGroupMemberDefinition member : surveyGroupMemberDefinitions)
    {
      if (member.getId().equals(id))
      {
        return member;
      }
    }

    return null;
  }

  /**
   * Returns the survey group member definitions associated with the survey group definition.
   *
   * @return the survey group member definitions associated with the survey group definition
   */
  public List<SurveyGroupMemberDefinition> getSurveyGroupMemberDefinitions()
  {
    return surveyGroupMemberDefinitions;
  }

  /**
   * Returns the version of the survey group definition.
   *
   * @return the version of the survey group definition
   */
  public int getVersion()
  {
    return version;
  }

  /**
   * Remove the survey group member definition from the survey group definition.
   *
   * @param id the Universally Unique Identifier (UUID) used  to uniquely identify the survey
   *           group member definition
   */
  public void removeSurveyGroupMemberDefinition(UUID id)
  {
    for (SurveyGroupMemberDefinition member : surveyGroupMemberDefinitions)
    {
      if (member.getId().equals(id))
      {
        surveyGroupMemberDefinitions.remove(member);

        return;
      }
    }
  }

  /**
   * Set the description for the survey group definition.
   *
   * @param description the description for the survey group definition
   */
  public void setDescription(String description)
  {
    this.description = description;
  }

  /**
   * Set the name of the survey group definition
   *
   * @param name the name of the survey group definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey group definition.
   *
   * @return the String representation of the survey group definition
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyDefinitionGroup {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("description=\"").append(getDescription()).append("\", ");

    buffer.append("surveyGroupMemberDefinitions={");

    for (int i = 0; i < surveyGroupMemberDefinitions.size(); i++)
    {
      if (i > 0)
      {
        buffer.append(", ");
      }

      buffer.append(surveyGroupMemberDefinitions.get(i));
    }

    buffer.append("}");

    buffer.append("}");

    return buffer.toString();
  }

  /**
   * Increment the version of the survey group definition.
   */
  void incrementVersion()
  {
    // Increment the survey group definition
    version++;

    // Increment the survey group member definitions
    surveyGroupMemberDefinitions.forEach(SurveyGroupMemberDefinition::incrementVersion);
  }

  /**
   * Set the survey definition this survey group definition is associated with.
   *
   * @param surveyDefinition the survey definition this survey group definition is associated with
   */
  void setSurveyDefinition(SurveyDefinition surveyDefinition)
  {
    this.surveyDefinition = surveyDefinition;
  }
}
