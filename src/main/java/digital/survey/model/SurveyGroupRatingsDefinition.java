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
@JsonPropertyOrder({ "id", "typeId", "name", "label", "help", "groupDefinitionId",
    "groupRatingDefinitions", "displayRatingsUsingGradient" })

public class SurveyGroupRatingsDefinition extends SurveyItemDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition for the survey group ratings definition.
   */
  private static final UUID TYPE_ID = UUID.fromString("aded36bd-bc3d-4157-99f6-b4d91825de5d");

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
   * @param name                        the short, unique name for the survey group ratings
   *                                    definition
   * @param label                       the user-friendly label for the survey group ratings
   *                                    definition
   * @param help                        the HTML help for the survey item definition
   * @param groupDefinitionId           the Universally Unique Identifier (UUID) used to uniquely
   *                                    identify the survey group definition this survey group
   *                                    ratings definition is associated with
   * @param displayRatingsUsingGradient should the ratings for the survey group rating responses
   *                                    associated with this survey group ratings definition be
   *                                    displayed using a color gradient when viewing the survey
   *                                    result
   */
  public SurveyGroupRatingsDefinition(UUID id, String name, String label, String help,
      UUID groupDefinitionId, boolean displayRatingsUsingGradient)
  {
    super(id, TYPE_ID, name, label, help);

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
   * Returns the String representation of the survey group ratings definition.
   *
   * @return the String representation of the survey group ratings definition
   */
  @Override
  public String toString()
  {
    int count;

    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyGroupRatingsDefinition {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("typeId=\"").append(getTypeId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("label=\"").append(getLabel()).append("\", ");

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
