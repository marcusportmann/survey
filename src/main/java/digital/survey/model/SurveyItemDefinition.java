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
@JsonSubTypes({ @JsonSubTypes.Type(name = "7708438e-b114-43d4-8fe5-b08aa5567e3a",
    value = SurveySectionDefinition.class) ,
    @JsonSubTypes.Type(name = "aded36bd-bc3d-4157-99f6-b4d91825de5d",
        value = SurveyGroupRatingsDefinition.class) })
@JsonPropertyOrder({ "id", "typeId", "name", "label", "description" })
public class SurveyItemDefinition
{
  /**
   * The description for the survey item definition.
   */
  @JsonProperty
  private String description;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the type of survey item
   * definition.
   */
  @JsonProperty
  private UUID typeId;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey item definition.
   */
  @JsonProperty
  private UUID id;

  /**
   * The short, unique name for the survey item definition.
   */
  @JsonProperty
  private String name;

  /**
   * The user-friendly label for the survey item definition.
   */
  @JsonProperty
  private String label;

  /**
   * Constructs a new <code>SurveyGroupRatingsDefinition</code>.
   */
  @SuppressWarnings("unused")
  SurveyItemDefinition() {}

  /**
   * Constructs a new <code>SurveyItemDefinition</code>.
   *
   * @param id          the Universally Unique Identifier (UUID) used to uniquely identify the
   *                    survey item definition
   * @param typeId      the Universally Unique Identifier (UUID) used to uniquely identify the type
   *                    of survey item definition
   * @param name        the short, unique name for the survey item definition
   * @param label       the user-friendly label for the survey item definition
   * @param description the description for the survey item definition
   */
  public SurveyItemDefinition(UUID id, UUID typeId, String name, String label, String description)
  {
    this.id = id;
    this.typeId = typeId;
    this.name = name;
    this.label = label;
    this.description = description;
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
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey item definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey item definition
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
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the type of survey item definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the type of survey item definition
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
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey item definition.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey item definition
   */
  public void setId(UUID id)
  {
    this.id = id;
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
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the type of survey item definition.
   *
   * @param typeId the Universally Unique Identifier (UUID) used to uniquely identify the type of survey item definition
   */
  public void setTypeId(UUID typeId)
  {
    this.typeId = typeId;
  }

  /**
   * Retrieve the survey group rating definition.
   *
   * @param itemDefinitions the list of survey item definitions
   * @param id              the Universally Unique Identifier (UUID) used to uniquely identify the
   *                        survey group rating definition
   *
   * @return the survey group rating definition or <code>null</code> if the survey group rating
   *         definition could not be found
   */
  public static SurveyGroupRatingDefinition getGroupRatingDefinition(List<SurveyItemDefinition> itemDefinitions, UUID id)
  {
    for (SurveyItemDefinition itemDefinition : itemDefinitions)
    {
      if (itemDefinition instanceof SurveyGroupRatingsDefinition)
      {
        SurveyGroupRatingsDefinition groupRatingsDefinition = (SurveyGroupRatingsDefinition)itemDefinition;

        for (SurveyGroupRatingDefinition groupRatingDefinition : groupRatingsDefinition.getGroupRatingDefinitions())
        {
          if (groupRatingDefinition.getId().equals(id))
          {
            return groupRatingDefinition;
          }
        }
      }
      else if (itemDefinition instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition)itemDefinition;

        SurveyGroupRatingDefinition groupRatingDefinition = sectionDefinition.getGroupRatingDefinition(id);

        if (groupRatingDefinition != null)
        {
          return groupRatingDefinition;
        }
      }
    }

    return null;
  }

}
