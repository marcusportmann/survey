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

import javax.enterprise.inject.Vetoed;
import javax.persistence.Transient;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveySectionDefinition</code> class implements the Survey Section Definition entity,
 * which represents the definition of a survey section that forms part of a survey definition.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "typeId", "name", "label", "description", "itemDefinitions" })
@Vetoed
public class SurveySectionDefinition extends SurveyItemDefinition
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition for the survey section definition.
   */
  public static final UUID TYPE_ID = UUID.fromString("7708438e-b114-43d4-8fe5-b08aa5567e3a");



  /**
   * The survey item definitions that are associated with the survey definition.
   */
  @JsonProperty
  private List<SurveyItemDefinition> itemDefinitions;

  /**
   * Constructs a new <code>SurveySectionDefinition</code>.
   */
  @SuppressWarnings("unused")
  SurveySectionDefinition() {}

  /**
   * Constructs a new <code>SurveySectionDefinition</code>.
   *
   * @param id          the Universally Unique Identifier (UUID) used to uniquely identify the
   *                    survey group ratings definition
   * @param name        the short, unique name for the survey group ratings definition
   * @param label       the user-friendly label for the survey group ratings definition
   * @param description the description for the survey group ratings definition
   */
  public SurveySectionDefinition(UUID id, String name, String label, String description)
  {
    super(id, TYPE_ID, name, label, description);

    this.itemDefinitions = new ArrayList<>();
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
    return SurveyItemDefinition.getGroupRatingDefinition(itemDefinitions, id);
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
   * Retrieve the survey group ratings definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           ratings definition
   *
   * @return the survey group ratings definition or <code>null</code> if the survey group ratings
   *         definition could not be found
   */
  public SurveyGroupRatingsDefinition getGroupRatingsDefinition(UUID id)
  {
    for (SurveyGroupRatingsDefinition groupRatingsDefinition : groupRatingsDefinitions)
    {
      if (groupRatingsDefinition.getId().equals(id))
      {
        return groupRatingsDefinition;
      }
    }

    return null;
  }

  /**
   * Returns the survey group ratings definitions that are associated with the survey section
   * definition.
   *
   * @return the survey group ratings definitions that are associated with the survey section
   *         definition
   */
  public List<SurveyGroupRatingsDefinition> getGroupRatingsDefinitions()
  {
    return groupRatingsDefinitions;
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
   * Remove the survey group ratings definition from the survey section definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           ratings definition
   */
  public void removeGroupRatingsDefinition(UUID id)
  {
    for (SurveyGroupRatingsDefinition groupRatingsDefinition : groupRatingsDefinitions)
    {
      if (groupRatingsDefinition.getId().equals(id))
      {
        groupRatingsDefinitions.remove(groupRatingsDefinition);

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
    return String.format("SurveySectionDefinition {id=\"%s\", name=\"%s\", description=\"%s\"}",
        getId(), getName(), getDescription());
  }
}
