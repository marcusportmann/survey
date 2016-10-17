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
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.UUID;
import java.util.function.Predicate;

/**
 * The <code>SurveyDefinition</code> class implements the Survey Definition entity, which represents
 * a version of a definition for a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@IdClass(VersionedId.class)
@Table(schema = "SURVEY", name = "SURVEY_DEFINITIONS")
public class SurveyDefinition
{
  /**
   * The Universally Unique Identifier (UUID) used, along with the version of the survey definition,
   * to uniquely identify the survey definition.
   */
  @Id
  private UUID id;

  /**
   * The version of the survey definition
   */
  @Id
  private int version;

  /**
   * The name of the survey definition.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The description for the survey definition.
   */
  @Column(name = "DESCRIPTION", nullable = false)
  private String description;

  /**
   * The survey group definitions that are associated with the survey definition.
   */
  @OneToMany(mappedBy = "surveyDefinition", cascade = CascadeType.ALL, fetch = FetchType.EAGER,
      orphanRemoval = true)
  @OrderBy("NAME ASC")
  private Set<SurveyGroupDefinition> surveyGroupDefinitions;

  /**
   * The survey group rating item definitions that are associated with the survey definition.
   */
  @OneToMany(mappedBy = "surveyDefinition", cascade = CascadeType.ALL, fetch = FetchType.EAGER,
      orphanRemoval = true)
  @OrderBy("NAME ASC")
  private Set<SurveyGroupRatingItemDefinition> surveyGroupRatingItemDefinitions;

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
   * @param id          the Universally Unique Identifier (UUID) used, along with the version of the
   *                    survey definition, to uniquely identify the survey definition
   * @param version     the version of the survey definition
   * @param name        the name of the survey definition
   * @param description the description for the survey definition
   */
  public SurveyDefinition(UUID id, int version, String name, String description)
  {
    this.id = id;
    this.version = version;
    this.name = name;
    this.description = description;
    this.surveyGroupDefinitions = new LinkedHashSet<>();
    this.surveyGroupRatingItemDefinitions = new LinkedHashSet<>();
  }

  /**
   * Add the survey group definition to the survey definition.
   *
   * @param group the survey group definition
   */
  public void addSurveyGroupDefinition(SurveyGroupDefinition group)
  {
    group.setSurveyDefinition(this);

    surveyGroupDefinitions.add(group);
  }

  /**
   * Add the survey group rating item definition to the survey definition.
   *
   * @param groupRatingItem the survey group rating item definition
   */
  public void addSurveyGroupRatingItemDefinition(SurveyGroupRatingItemDefinition groupRatingItem)
  {
    groupRatingItem.setSurveyDefinition(this);

    surveyGroupRatingItemDefinitions.add(groupRatingItem);
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
   * Returns the description for the survey definition.
   *
   * @return the description for the survey definition
   */
  public String getDescription()
  {
    return description;
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
   * Retrieve the survey group definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           group definition
   *
   * @return the survey group definition or <code>null</code> if the survey group definition could
   *         not be found
   */
  public SurveyGroupDefinition getSurveyGroupDefinition(UUID id)
  {
    for (SurveyGroupDefinition group : surveyGroupDefinitions)
    {
      if (group.getId().equals(id))
      {
        return group;
      }
    }

    return null;
  }

  /**
   * Returns the survey group definitions that are associated with the survey definition.
   *
   * @return the survey group definitions that are associated with the survey definition
   */
  public Set<SurveyGroupDefinition> getSurveyGroupDefinitions()
  {
    return surveyGroupDefinitions;
  }

  /**
   * Retrieve the survey group rating item definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           group rating item definition
   *
   * @return the survey group rating item definition or <code>null</code> if the survey group rating
   *         item definition could not be found
   */
  public SurveyGroupRatingItemDefinition getSurveyGroupRatingItemDefinition(UUID id)
  {
    for (SurveyGroupRatingItemDefinition groupRatingItem : surveyGroupRatingItemDefinitions)
    {
      if (groupRatingItem.getId().equals(id))
      {
        return groupRatingItem;
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
  public Set<SurveyGroupRatingItemDefinition> getSurveyGroupRatingItemDefinitions()
  {
    return surveyGroupRatingItemDefinitions;
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
  public void removeSurveyGroupDefinition(UUID id)
  {
    for (SurveyGroupDefinition group : surveyGroupDefinitions)
    {
      if (group.getId().equals(id))
      {
        surveyGroupDefinitions.remove(group);

        Predicate<SurveyGroupRatingItemDefinition> groupRatingItemPredicate = p -> p.getSurveyGroupDefinition()
            == group;

        surveyGroupRatingItemDefinitions.removeIf(groupRatingItemPredicate);

        return;
      }
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

    buffer.append("surveyGroupDefinitions={");

    count = 0;

    for (SurveyGroupDefinition group : surveyGroupDefinitions)
    {
      if (count > 0)
      {
        buffer.append(", ");
      }

      buffer.append(group);

      count++;
    }

    buffer.append("}, ");

    buffer.append("surveyGroupRatingItemDefinitions={");

    count = 0;

    for (SurveyGroupRatingItemDefinition groupRatingItem : surveyGroupRatingItemDefinitions)
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
}
