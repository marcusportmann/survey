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
import com.fasterxml.jackson.annotation.JsonSubTypes;
import com.fasterxml.jackson.annotation.JsonTypeInfo;

import java.io.Serializable;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyItemDefinition</code> implements the Survey Item Definition entity, which
 * represents the definition of a survey item that forms part of a survey definition.
 *
 * @author Marcus Portmann
 */
@JsonTypeInfo(use = JsonTypeInfo.Id.NAME, include = JsonTypeInfo.As.PROPERTY, property = "typeId")
@JsonSubTypes({ @JsonSubTypes.Type(name = "aded36bd-bc3d-4157-99f6-b4d91825de5d",
    value = SurveyGroupRatingsDefinition.class) ,
    @JsonSubTypes.Type(name = "7708438e-b114-43d4-8fe5-b08aa5567e3a",
        value = SurveySectionDefinition.class) ,
    @JsonSubTypes.Type(name = "491253d9-e6cf-4692-bcfd-39bcd8960a60",
        value = SurveyTextDefinition.class) })
@JsonPropertyOrder({ "id", "typeId", "name", "label", "description", "help" })
public abstract class SurveyItemDefinition
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The description for the survey item definition.
   */
  @JsonProperty
  private String description;

  /**
   * The HTML help for the survey item definition.
   */
  @JsonProperty
  private String help;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey item definition.
   */
  @JsonProperty
  private UUID id;

  /**
   * The user-friendly label for the survey item definition.
   */
  @JsonProperty
  private String label;

  /**
   * The short, unique name for the survey item definition.
   */
  @JsonProperty
  private String name;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition.
   */
  @JsonProperty
  private UUID typeId;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinition</code>.
   */
  @SuppressWarnings("unused")
  SurveyItemDefinition() {}

  /**
   * Constructs a new <code>SurveyItemDefinition</code>.
   *
   * @param typeId      the Universally Unique Identifier (UUID) used to uniquely identify the type
   *                    of survey item definition
   * @param name        the short, unique name for the survey item definition
   * @param label       the user-friendly label for the survey item definition
   * @param description the description for the survey item definition
   * @param help        the HTML help for the survey item definition
   */
  public SurveyItemDefinition(UUID typeId, String name, String label, String description,
      String help)
  {
    this.id = UUID.randomUUID();
    this.typeId = typeId;
    this.name = name;
    this.label = label;
    this.description = description;
    this.help = help;
  }

  /**
   * Returns whether the survey item definition is in the list of survey item definitions.
   *
   * @param itemDefinitions the survey item definitions
   * @param itemDefinition  the survey item definition
   *
   * @return <code>true</code> if the survey item definition is in the list of survey item
   *         definitions or <code>false</code> otherwise
   */
  public static boolean hasItemDefinition(List<SurveyItemDefinition> itemDefinitions,
      SurveyItemDefinition itemDefinition)
  {
    for (SurveyItemDefinition tmpItemDefinition : itemDefinitions)
    {
      if (tmpItemDefinition.getId().equals(itemDefinition.getId()))
      {
        return true;
      }
    }

    return false;
  }

  /**
   * Recursively checks whether the survey item definition is the first survey item definition.
   *
   * @param itemDefinitions the survey item definitions
   * @param itemDefinition  the survey item definition
   *
   * @return <code>true</code> if the survey item definition is the first survey item definition or
   *         <code>false</code> otherwise
   */
  public static boolean isFirstItemDefinition(List<SurveyItemDefinition> itemDefinitions,
      SurveyItemDefinition itemDefinition)
  {
    for (int i = 0; i < itemDefinitions.size(); i++)
    {
      SurveyItemDefinition tmpItemDefinition = itemDefinitions.get(i);

      if (tmpItemDefinition.getId().equals(itemDefinition.getId()))
      {
        return i == 0;
      }
    }

    for (SurveyItemDefinition tmpItemDefinition : itemDefinitions)
    {
      if (tmpItemDefinition instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) tmpItemDefinition;

        if (sectionDefinition.isFirstItemDefinition(itemDefinition))
        {
          return true;
        }
      }
    }

    return false;
  }

  /**
   * Recursively checks whether the survey item definition is the last survey item definition.
   *
   * @param itemDefinitions the list of survey item definitions
   * @param itemDefinition  the survey item definition
   *
   * @return <code>true</code> if the survey item definition is the last survey item definition or
   *         <code>false</code> otherwise
   */
  public static boolean isLastItemDefinition(List<SurveyItemDefinition> itemDefinitions,
      SurveyItemDefinition itemDefinition)
  {
    for (int i = 0; i < itemDefinitions.size(); i++)
    {
      SurveyItemDefinition tmpItemDefinition = itemDefinitions.get(i);

      if (tmpItemDefinition.getId().equals(itemDefinition.getId()))
      {
        return i == (itemDefinitions.size() - 1);
      }
    }

    for (SurveyItemDefinition tmpItemDefinition : itemDefinitions)
    {
      if (tmpItemDefinition instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) tmpItemDefinition;

        if (sectionDefinition.isLastItemDefinition(itemDefinition))
        {
          return true;
        }
      }
    }

    return false;
  }

  /**
   * Move the specified survey item definition one step down in the list of survey item definitions.
   *
   * @param itemDefinitions the list of survey item definitions
   * @param itemDefinition  the survey item definition
   *
   * @return <code>true</code> if the survey item definition was successfully moved down or
   *         <code>false</code> otherwise
   */
  public static boolean moveItemDefinitionDown(List<SurveyItemDefinition> itemDefinitions,
      SurveyItemDefinition itemDefinition)
  {
    int index = itemDefinitions.indexOf(itemDefinition);

    if ((index >= 0) && (index < (itemDefinitions.size() - 1)))
    {
      itemDefinitions.remove(index);

      itemDefinitions.add(index + 1, itemDefinition);

      return true;
    }

    for (SurveyItemDefinition tmpItemDefiniton : itemDefinitions)
    {
      if (tmpItemDefiniton instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) tmpItemDefiniton;

        if (sectionDefinition.moveItemDefinitionDown(itemDefinition))
        {
          return true;
        }
      }
    }

    return false;
  }

  /**
   * Move the specified survey item definition one step up in the list of survey item definitions.
   *
   * @param itemDefinitions the list of survey item definitions
   * @param itemDefinition  the survey item definition
   *
   * @return <code>true</code> if the survey item definition was successfully moved up
   *         or <code>false</code> otherwise
   */
  public static boolean moveItemDefinitionUp(List<SurveyItemDefinition> itemDefinitions,
      SurveyItemDefinition itemDefinition)
  {
    int index = itemDefinitions.indexOf(itemDefinition);

    if (index > 0)
    {
      itemDefinitions.remove(index);

      itemDefinitions.add(index - 1, itemDefinition);

      return true;
    }

    for (SurveyItemDefinition tmpItemDefiniton : itemDefinitions)
    {
      if (tmpItemDefiniton instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) tmpItemDefiniton;

        if (sectionDefinition.moveItemDefinitionUp(itemDefinition))
        {
          return true;
        }
      }
    }

    return false;
  }

  /**
   * Remove the survey item definition with the specified ID from the list of survey item
   * definitions
   *
   * @param itemDefinitions the list of survey item definitions
   * @param itemDefinition  the survey item definition
   *
   * @return <code>true</code> if the survey item definition was removed or <code>false</code>
   *         otherwise
   */
  public static boolean removeItemDefinition(List<SurveyItemDefinition> itemDefinitions,
      SurveyItemDefinition itemDefinition)
  {
    for (SurveyItemDefinition tmpItemDefinition : itemDefinitions)
    {
      if (tmpItemDefinition.getId().equals(itemDefinition.getId()))
      {
        itemDefinitions.remove(itemDefinition);

        return true;
      }
    }

    for (SurveyItemDefinition tmpItemDefiniton : itemDefinitions)
    {
      if (tmpItemDefiniton instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) tmpItemDefiniton;

        if (sectionDefinition.removeItemDefinition(itemDefinition))
        {
          return true;
        }
      }
    }

    return false;
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

    SurveyItemDefinition other = (SurveyItemDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the description for the survey item definition.
   *
   * @return the description for the survey item definition
   */
  public String getDescription()
  {
    return description;
  }

  /**
   * Returns the HTML help for the survey item definition.
   *
   * @return the HTML help for the survey item definition
   */
  public String getHelp()
  {
    return help;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey item
   * definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey item
   *         definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the user-friendly label for the survey item definition.
   *
   * @return the user-friendly label for the survey item definition
   */
  public String getLabel()
  {
    return label;
  }

  /**
   * Returns the short, unique name for the survey item definition.
   *
   * @return the short, unique name for the survey item definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the type of survey
   * item definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the type of survey
   *         item definition
   */
  public UUID getTypeId()
  {
    return typeId;
  }

  /**
   * Set the description for the survey item definition.
   *
   * @param description the description for the survey item definition
   */
  public void setDescription(String description)
  {
    this.description = description;
  }

  /**
   * Set the HTML help for the survey item definition.
   *
   * @param help the HTML help for the survey item definition
   */
  public void setHelp(String help)
  {
    this.help = help;
  }

  /**
   * Set the user-friendly label for the survey item definition.
   *
   * @param label the user-friendly label for the survey item definition
   */
  public void setLabel(String label)
  {
    this.label = label;
  }

  /**
   * Set the short, unique name for the survey item definition.
   *
   * @param name the short, unique name for the survey item definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Returns the String representation of the survey item definition.
   *
   * @return the String representation of the survey item definition
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyItemDefinition {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("typeId=\"").append(getTypeId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\", ");
    buffer.append("label=\"").append(getLabel()).append("\", ");
    buffer.append("description=\"").append(getDescription()).append("\"}");

    return buffer.toString();
  }
}
