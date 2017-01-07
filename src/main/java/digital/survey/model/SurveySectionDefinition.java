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
   * @param id          the Universally Unique Identifier (UUID) used to uniquely identify the
   *                    survey section definition
   * @param name        the short, unique name for the survey section definition
   * @param label       the user-friendly label for the section definition
   * @param description the description for the survey section definition
   */
  public SurveySectionDefinition(UUID id, String name, String label, String description)
  {
    super(id, TYPE_ID, name, label, description);

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
   * Returns whether the survey item definition is the first survey item definition for the survey
   * section definition.
   *
   * @param itemDefinition the survey item definition
   *
   * @return <code>true</code> if the survey item definition is the first survey item definition for
   *         the survey section definition or <code>false</code> otherwise
   */
  public boolean isFirstItemDefinition(SurveyItemDefinition itemDefinition)
  {
    return SurveyItemDefinition.isFirstItemDefinition(itemDefinitions, itemDefinition);
  }

  /**
   * Returns whether the survey item definition is the first last item definition for the survey
   * section definition.
   *
   * @param itemDefinition the survey item definition
   *
   * @return <code>true</code> if the survey item definition is the last survey item definition for
   *         the survey section definition or <code>false</code> otherwise
   */
  public boolean isLastItemDefinition(SurveyItemDefinition itemDefinition)
  {
    return SurveyItemDefinition.isLastItemDefinition(itemDefinitions, itemDefinition);
  }

  /**
   * Remove the survey item definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey item
   *           definition
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
