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
@JsonPropertyOrder({ "id", "typeId", "name", "label", "description", "help",
    "groupRatingDefinitions", "groupMemberDefinitions", "displayRatingsUsingGradient" })

public class SurveyGroupRatingsDefinition extends SurveyItemDefinition
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition for the survey group ratings definition.
   */
  public static final String TYPE_ID = "aded36bd-bc3d-4157-99f6-b4d91825de5d";

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition for the survey group ratings definition.
   */
  private static final UUID TYPE_UUID = UUID.fromString(TYPE_ID);

  /**
   * The survey group member definitions associated with the survey group ratings definition.
   */
  @JsonProperty
  private List<SurveyGroupMemberDefinition> groupMemberDefinitions;

  /**
   * Should the ratings for the survey group rating responses associated with this survey group
   * ratings definition be displayed using a color gradient when viewing the survey result.
   */
  @JsonProperty
  private boolean displayRatingsUsingGradient;

  /**
   * The survey group rating definitions that are associated with the survey group ratings
   * definition.
   */
  @JsonProperty
  private List<SurveyGroupRatingDefinition> groupRatingDefinitions;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinition</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingsDefinition() {}

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinition</code>.
   *
   * @param name                        the short, unique name for the survey group ratings
   *                                    definition
   * @param label                       the user-friendly label for the survey group ratings
   *                                    definition
   * @param description                 the description for the survey group ratings definition
   * @param help                        the HTML help for the survey group ratings definition
   * @param displayRatingsUsingGradient should the ratings for the survey group rating responses
   *                                    associated with this survey group ratings definition be
   *                                    displayed using a color gradient when viewing the survey
   *                                    result
   */
  public SurveyGroupRatingsDefinition(String name, String label, String description, String help,
      boolean displayRatingsUsingGradient)
  {
    super(TYPE_UUID, name, label, description, help);

    this.displayRatingsUsingGradient = displayRatingsUsingGradient;
    this.groupRatingDefinitions = new ArrayList<>();
    this.groupMemberDefinitions = new ArrayList<>();
  }

  /**
   * Add the survey group member definition to the survey group ratings definition.
   *
   * @param groupMemberDefinition the survey group member definition
   */
  public void addGroupMemberDefinition(SurveyGroupMemberDefinition groupMemberDefinition)
  {
    groupMemberDefinitions.add(groupMemberDefinition);
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
   * Retrieve the survey group member definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           group member definition
   *
   * @return the survey group member definition or <code>null</code> if the survey group member
   *         definition could not be found
   */
  public SurveyGroupMemberDefinition getGroupMemberDefinition(UUID id)
  {
    for (SurveyGroupMemberDefinition groupMemberDefinition : groupMemberDefinitions)
    {
      if (groupMemberDefinition.getId().equals(id))
      {
        return groupMemberDefinition;
      }
    }

    return null;
  }

  /**
   * Returns the survey group member definitions associated with the survey group definition.
   *
   * @return the survey group member definitions associated with the survey group definition
   */
  public List<SurveyGroupMemberDefinition> getGroupMemberDefinitions()
  {
    return groupMemberDefinitions;
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
   * Move the specified survey group member definition one step down in the list of survey group
   * member definitions.
   *
   * @param groupMemberDefinition the survey group member definition
   *
   * @return <code>true</code> if the survey group member definition was successfully moved down
   *         or <code>false</code> otherwise
   */
  public boolean moveGroupMemberDefinitionDown(SurveyGroupMemberDefinition groupMemberDefinition)
  {
    int index = groupMemberDefinitions.indexOf(groupMemberDefinition);

    if ((index >= 0) && (index < (groupMemberDefinitions.size() - 1)))
    {
      groupMemberDefinitions.remove(index);

      groupMemberDefinitions.add(index + 1, groupMemberDefinition);

      return true;
    }

    return false;
  }

  /**
   * Move the specified survey group member definition one step up in the list of survey group
   * member definitions.
   *
   * @param groupMemberDefinition the survey group member definition
   *
   * @return <code>true</code> if the survey group member definition was successfully moved up
   *         or <code>false</code> otherwise
   */
  public boolean moveGroupMemberDefinitionUp(SurveyGroupMemberDefinition groupMemberDefinition)
  {
    int index = groupMemberDefinitions.indexOf(groupMemberDefinition);

    if (index > 0)
    {
      groupMemberDefinitions.remove(index);

      groupMemberDefinitions.add(index - 1, groupMemberDefinition);

      return true;
    }

    return false;
  }

  /**
   * Move the specified survey group rating definition one step down in the list of survey group
   * rating definitions.
   *
   * @param groupRatingDefinition the survey group rating definition
   *
   * @return <code>true</code> if the survey group rating definition was successfully moved down
   *         or <code>false</code> otherwise
   */
  public boolean moveGroupRatingDefinitionDown(SurveyGroupRatingDefinition groupRatingDefinition)
  {
    int index = groupRatingDefinitions.indexOf(groupRatingDefinition);

    if ((index >= 0) && (index < (groupRatingDefinitions.size() - 1)))
    {
      groupRatingDefinitions.remove(index);

      groupRatingDefinitions.add(index + 1, groupRatingDefinition);

      return true;
    }

    return false;
  }

  /**
   * Move the specified survey group rating definition up step down in the list of survey group
   * rating definitions.
   *
   * @param groupRatingDefinition the survey group rating definition
   *
   * @return <code>true</code> if the survey group rating definition was successfully moved up
   *         or <code>false</code> otherwise
   */
  public boolean moveGroupRatingDefinitionUp(SurveyGroupRatingDefinition groupRatingDefinition)
  {
    int index = groupRatingDefinitions.indexOf(groupRatingDefinition);

    if (index > 0)
    {
      groupRatingDefinitions.remove(index);

      groupRatingDefinitions.add(index - 1, groupRatingDefinition);

      return true;
    }

    return false;
  }

  /**
   * Remove the survey group member definition from the survey group ratings definition.
   *
   * @param groupMemberDefinition the survey group member definition
   */
  public void removeGroupMemberDefinition(SurveyGroupMemberDefinition groupMemberDefinition)
  {
    for (SurveyGroupMemberDefinition tmpGroupMemberDefinition : groupMemberDefinitions)
    {
      if (tmpGroupMemberDefinition.getId().equals(groupMemberDefinition.getId()))
      {
        groupMemberDefinitions.remove(tmpGroupMemberDefinition);

        return;
      }
    }
  }

  /**
   * Remove the survey group member definition from the survey group ratings definition.
   *
   * @param id the Universally Unique Identifier (UUID) used  to uniquely identify the survey
   *           group member definition
   */
  public void removeGroupMemberDefinition(UUID id)
  {
    for (SurveyGroupMemberDefinition groupMemberDefinition : groupMemberDefinitions)
    {
      if (groupMemberDefinition.getId().equals(id))
      {
        groupMemberDefinitions.remove(groupMemberDefinition);

        return;
      }
    }
  }

  /**
   * Remove the survey group rating definition from the survey group ratings definition.
   *
   * @param groupRatingDefinition the survey group rating definition
   */
  public void removeGroupRatingDefinition(SurveyGroupRatingDefinition groupRatingDefinition)
  {
    for (SurveyGroupRatingDefinition tmpGroupRatingDefinition : groupRatingDefinitions)
    {
      if (tmpGroupRatingDefinition.getId().equals(groupRatingDefinition.getId()))
      {
        groupRatingDefinitions.remove(tmpGroupRatingDefinition);

        return;
      }
    }
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
    buffer.append("description=\"").append(getDescription()).append("\", ");

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

    buffer.append("}, ");

    buffer.append("groupMemberDefinitions={");

    count = 0;

    for (SurveyGroupMemberDefinition groupMemberDefinition : groupMemberDefinitions)
    {
      if (count > 0)
      {
        buffer.append(", ");
      }

      buffer.append(groupMemberDefinition);

      count++;
    }

    buffer.append("}");

    buffer.append("}");

    return buffer.toString();
  }
}
