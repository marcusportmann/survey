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

import javax.enterprise.inject.Vetoed;
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
@JsonPropertyOrder({ "id", "typeId", "name", "label", "description", "help", "itemDefinitions" })
@Vetoed
public class SurveySectionDefinition extends SurveyItemDefinition
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition for the survey section definition.
   */
  public static final String TYPE_ID = "7708438e-b114-43d4-8fe5-b08aa5567e3a";

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition for the survey section definition.
   */
  private static final UUID TYPE_UUID = UUID.fromString(TYPE_ID);

  /**
   * The survey item definitions that are associated with the survey section definition.
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
   * @param name        the short, unique name for the survey section definition
   * @param label       the user-friendly label for the section definition
   * @param description the description for the survey section definition
   * @param help        the HTML help for the survey section definition
   */
  public SurveySectionDefinition(String name, String label, String description, String help)
  {
    super(TYPE_UUID, name, label, description, help);

    this.itemDefinitions = new ArrayList<>();
  }

  /**
   * Add the survey item definition to the survey section definition.
   *
   * @param itemDefinition the survey item definition
   */
  public void addItemDefinition(SurveyItemDefinition itemDefinition)
  {
    itemDefinitions.add(itemDefinition);
  }

  /**
   * Returns all the survey item definitions associated with the survey definition.
   *
   * @return all the survey item definitions associated with the survey definition
   */
  @JsonIgnore
  public List<SurveyItemDefinition> getAllItemDefinitions()
  {
    List<SurveyItemDefinition> allItemDefinitions = new ArrayList<>();

    allItemDefinitions.addAll(itemDefinitions);

    for (SurveyItemDefinition itemDefinition : itemDefinitions)
    {
      if (itemDefinition instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) itemDefinition;

        allItemDefinitions.addAll(sectionDefinition.getAllItemDefinitions());
      }
    }

    return allItemDefinitions;
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
   * Is the survey group rating definition with the specified ID associated with the survey
   * section definition?
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating definition
   *
   * @return <code>true</code> if the survey group rating definition with the specified ID is
   *         associated with the survey section definition or <code>false</code> otherwise
   */
  public boolean hasGroupRatingDefinition(UUID id)
  {
    for (SurveyItemDefinition itemDefinition : itemDefinitions)
    {
      if (itemDefinition instanceof SurveyGroupRatingsDefinition)
      {
        SurveyGroupRatingsDefinition surveyGroupRatingsDefinition =
            (SurveyGroupRatingsDefinition) itemDefinition;

        if (surveyGroupRatingsDefinition.getGroupRatingDefinition(id) != null)
        {
          return true;
        }
      }
    }

    return false;
  }

  /**
   * Remove the survey item definition.
   *
   * @param itemDefinition the survey item definition
   *
   * @return <code>true</code> if the survey item definition was removed or <code>false</code>
   *         otherwise
   */
  public boolean removeItemDefinition(SurveyItemDefinition itemDefinition)
  {
    return SurveyItemDefinition.removeItemDefinition(itemDefinitions, itemDefinition);
  }

  /**
   * Returns the String representation of the survey section definition.
   *
   * @return the String representation of the survey section definition
   */
  @Override
  public String toString()
  {
    int count;

    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveySectionDefinition {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("typeId=\"").append(getTypeId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("label=\"").append(getLabel()).append("\", ");

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
}
