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
 * The <code>SurveySectionDefinition</code> class implements the Survey Section Definition entity,
 * which represents a version of a definition for a survey section.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "name", "description", "groupMemberDefinitions" })
public class SurveySectionDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey section
   * definition.
   */
  @JsonProperty
  private UUID id;

  /**
   * The name of the survey section definition.
   */
  @JsonProperty
  private String name;

  /**
   * The description for the survey section definition.
   */
  @JsonProperty
  private String description;

  /**
   * The survey group rating item definitions that are associated with the survey section
   * definition.
   */
  @JsonProperty
  private List<SurveyGroupRatingItemDefinition> groupRatingItemDefinitions;

  /**
   * Constructs a new <code>SurveySectionDefinition</code>.
   */
  @SuppressWarnings("unused")
  SurveySectionDefinition() {}

  /**
   * Constructs a new <code>SurveySectionDefinition</code>.
   *
   * @param id          the Universally Unique Identifier (UUID) used to uniquely identify the
   *                    survey section definition
   * @param name        the name of the survey section definition
   * @param description the description for the survey section definition
   */
  public SurveySectionDefinition(UUID id, String name, String description)
  {
    this.id = id;
    this.name = name;
    this.description = description;
    this.groupRatingItemDefinitions = new ArrayList<>();
  }

  /**
   * Add the survey group rating item definition to the survey section definition.
   *
   * @param groupRatingItemDefinition the survey group rating item definition
   */
  public void addGroupRatingItemDefinition(
      SurveyGroupRatingItemDefinition groupRatingItemDefinition)
  {
    groupRatingItemDefinitions.add(groupRatingItemDefinition);
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

    SurveySectionDefinition other = (SurveySectionDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the description for the survey section definition.
   *
   * @return the description for the survey section definition
   */
  public String getDescription()
  {
    return description;
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
   * Returns the survey group rating item definitions that are associated with the survey section
   * definition.
   *
   * @return the survey group rating item definitions that are associated with the survey section
   *         definition
   */
  public List<SurveyGroupRatingItemDefinition> getGroupRatingItemDefinitions()
  {
    return groupRatingItemDefinitions;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey section
   * definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey section
   *         definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey section definition.
   *
   * @return the name of the survey section definition
   */
  public String getName()
  {
    return name;
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
   * Set the description for the survey section definition.
   *
   * @param description the description for the survey section definition
   */
  public void setDescription(String description)
  {
    this.description = description;
  }

  /**
   * Set the name of the survey section definition.
   *
   * @param name the name of the survey section definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey section definition.
   *
   * @return the String representation of the survey section definition
   */
  @Override
  public String toString()
  {
    return String.format("SurveySectionDefinition {id=\"%s\", name=\"%s\"}", getId(), getName());
  }
}
