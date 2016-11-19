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

import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingsDefinition</code> class implements the Survey Group Ratings
 * Definition entity, which represents a set of ratings that can be captured for each member of a
 * group of entities associated with a survey.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "name", "groupDefinitionId", "displayRatingsUsingGradient" })

public class SurveyGroupRatingsDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group ratings
   * definition.
   */
  @JsonProperty
  private UUID id;

  /**
   * The name of the survey group ratings definition.
   */
  @JsonProperty
  private String name;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group definition
   * this survey group ratings definition is associated with.
   */
  @JsonProperty
  private UUID groupDefinitionId;

  /**
   * The survey group rating definitions that are associated with the survey group ratings
   * definition.
   */
  @JsonProperty
  private List<SurveyGroupRatingDefinition> groupRatingDefinitions;

  /**
   * Should the ratings for the survey group rating responses associated with this survey group
   * ratings definition be displayed using a color gradient when viewing the survey result.
   */
  @JsonProperty
  private boolean displayRatingsUsingGradient;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinition</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingsDefinition() {}

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinition</code>.
   *
   * @param id                          the Universally Unique Identifier (UUID) used to uniquely
   *                                    identify the survey group ratings definition
   * @param name                        the name of the survey group ratings definition
   * @param groupDefinitionId           the Universally Unique Identifier (UUID) used to uniquely
   *                                    identify the survey group definition this survey group
   *                                    ratings definition is associated with
   * @param displayRatingsUsingGradient should the ratings for the survey group rating responses
   *                                    associated with this survey group ratings definition be
   *                                    displayed using a color gradient when viewing the survey
   *                                    result
   */
  public SurveyGroupRatingsDefinition(UUID id, String name, UUID groupDefinitionId,
      boolean displayRatingsUsingGradient)
  {
    this.id = id;
    this.name = name;
    this.groupDefinitionId = groupDefinitionId;
    this.displayRatingsUsingGradient = displayRatingsUsingGradient;
    this.groupRatingDefinitions = new ArrayList<>();
  }

  /**
   * Add the survey group rating definition to the survey group ratings definition.
   *
   * @param groupRatingDefinition the survey group rating definition
   */
  public void addGroupRatingDefinition(SurveyGroupRatingDefinition groupRatingDefinition)
  {
    groupRatingDefinitions.add(groupRatingDefinition);
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

    SurveyGroupRatingsDefinition other = (SurveyGroupRatingsDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns whether the ratings for the survey group rating responses associated with this survey
   * group ratings definition should be displayed using a color gradient when viewing the survey
   * result.
   *
   * @return <code>true</code> if the ratings for the survey group rating responses associated with
   *         this survey group ratings definition should be displayed using a color gradient when
   *         viewing the survey result or <code>false</code> otherwise
   */
  public boolean getDisplayRatingsUsingGradient()
  {
    return displayRatingsUsingGradient;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * definition this survey group ratings definition is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         definition this survey group ratings definition is associated with
   */
  public UUID getGroupDefinitionId()
  {
    return groupDefinitionId;
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
    for (SurveyGroupRatingDefinition groupRatingDefinition : groupRatingDefinitions)
    {
      if (groupRatingDefinition.getId().equals(id))
      {
        return groupRatingDefinition;
      }
    }

    return null;
  }

  /**
   * Returns the survey group rating definitions that are associated with the survey group ratings
   * definition.
   *
   * @return the survey group rating definitions that are associated with the survey group ratings
   *         definition
   */
  public List<SurveyGroupRatingDefinition> getGroupRatingDefinitions()
  {
    return groupRatingDefinitions;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * ratings definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         ratings definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey group ratings definition,
   *
   * @return the name of the survey group ratings definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Remove the survey group rating definition from the survey group ratings definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating definition
   */
  public void removeGroupRatingDefinition(UUID id)
  {
    for (SurveyGroupRatingDefinition groupRatingDefinition : groupRatingDefinitions)
    {
      if (groupRatingDefinition.getId().equals(id))
      {
        groupRatingDefinitions.remove(groupRatingDefinition);

        return;
      }
    }
  }

  /**
   * Set whether the ratings for the survey group rating responses associated with this survey group
   * ratings definition be displayed using a color gradient when viewing the survey result.
   *
   * @param displayRatingsUsingGradient <code>true</code> if the ratings for the survey group rating
   *                                    responses associated with this survey group ratings
   *                                    definition should be displayed using a color gradient when
   *                                    viewing the survey result or <code>false</code> otherwise
   */
  public void setDisplayRatingsUsingGradient(boolean displayRatingsUsingGradient)
  {
    this.displayRatingsUsingGradient = displayRatingsUsingGradient;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * definition this survey group ratings definition is associated with.
   *
   * @param groupDefinitionId the Universally Unique Identifier (UUID) used to uniquely identify
   *                          the survey group definition this survey group ratings definition is
   *                          associated with
   */
  public void setGroupDefinitionId(UUID groupDefinitionId)
  {
    this.groupDefinitionId = groupDefinitionId;
  }

  /**
   * Set the survey group rating definitions that are associated with the survey group ratings
   * definition.
   *
   * @param groupRatingDefinitions the survey group rating definitions that are associated with the
   *                               survey group ratings definition
   */
  public void setGroupRatingDefinitions(List<SurveyGroupRatingDefinition> groupRatingDefinitions)
  {
    this.groupRatingDefinitions = groupRatingDefinitions;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey group ratings
   * definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           ratings definition
   */
  public void setId(UUID id)
  {
    this.id = id;
  }

  /**
   * Set the name of the survey group ratings definition.
   *
   * @param name the name of the survey group ratings definition
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
    buffer.append("name=\"").append(getName()).append("\", ");

    buffer.append("groupRatingDefinitions={");

    count = 0;

    for (SurveyGroupRatingDefinition groupRatingDefinition : groupRatingDefinitions)
    {
      if (count > 0)
      {
        buffer.append(", ");
      }

      buffer.append(groupRatingDefinition);

      count++;
    }

    buffer.append("}");

    buffer.append("}");

    return buffer.toString();
  }
}
