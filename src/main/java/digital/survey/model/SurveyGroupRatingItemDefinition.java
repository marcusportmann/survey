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
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingItemDefinition</code> class implements the Survey Group Rating Item
 * Definition entity, which represents the definition for a group rating item that forms part of a
 * survey definition.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "name", "groupDefinitionId", "ratingType",
    "displayRatingUsingGradient" })
public class SurveyGroupRatingItemDefinition
  implements Serializable
{
  /**
   * Should the rating for a survey group rating item response associated with this survey group rating item definition be displayed using a color gradient when viewing the survey result.
   */
  @JsonProperty
  private boolean displayRatingUsingGradient;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating item
   * definition.
   */
  @JsonProperty
  private UUID id;

  /**
   * The name of the survey group rating item definition.
   */
  @JsonProperty
  private String name;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group definition
   * this survey group rating item definition is associated with.
   */
  @JsonProperty
  private UUID groupDefinitionId;

  /**
   * The type of survey group rating item.
   */
  @JsonProperty
  private SurveyGroupRatingItemType ratingType;

  /**
   * Constructs a new <code>SurveyDefinitionGroupRatingItem</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingItemDefinition() {}

  /**
   * Constructs a new <code>SurveyDefinitionGroupRatingItem</code>.
   *
   * @param id                         the Universally Unique Identifier (UUID) used to uniquely
   *                                   identify the survey group rating item definition
   * @param name                       the name of the survey group rating item definition
   * @param groupDefinitionId          the Universally Unique Identifier (UUID) used to uniquely
   *                                   identify the survey group definition this survey group rating
   *                                   item definition is associated with
   * @param ratingType                 the type of survey group rating item
   * @param displayRatingUsingGradient should the rating for a survey group rating item response
   *                                   associated with this survey group rating item definition be
   *                                   displayed using a color gradient when viewing the survey
   *                                   result
   */
  public SurveyGroupRatingItemDefinition(UUID id, String name, UUID groupDefinitionId,
      SurveyGroupRatingItemType ratingType, boolean displayRatingUsingGradient)
  {
    this.id = id;
    this.name = name;
    this.groupDefinitionId = groupDefinitionId;
    this.ratingType = ratingType;
    this.displayRatingUsingGradient = displayRatingUsingGradient;
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

    SurveyGroupRatingItemDefinition other = (SurveyGroupRatingItemDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns whether the rating for a survey group rating item response associated with this survey
   * group rating item definition be displayed using a color gradient when viewing the survey
   * result.
   *
   * @return <code>true</code> if the rating for a survey group rating item response associated with
   *         this survey group rating item definition be displayed using a color gradient when
   *         viewing the survey result or <code>false</code> otherwise
   */
  public boolean getDisplayRatingUsingGradient()
  {
    return displayRatingUsingGradient;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * definition this survey group rating item definition is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         definition this survey group rating item definition is associated with
   */
  public UUID getGroupDefinitionId()
  {
    return groupDefinitionId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating item definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating item definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey group rating item definition.
   *
   * @return the name of the survey group rating item definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the type of survey group rating item.
   *
   * @return the type of survey group rating item
   */
  public SurveyGroupRatingItemType getRatingType()
  {
    return ratingType;
  }

  /**
   * Set whether the rating for a survey group rating item response associated with this survey
   * group rating item definition be displayed using a color gradient when viewing the survey
   * result.
   *
   * @param displayRatingUsingGradient should the rating for a survey group rating item response
   *                                   associated with this survey group rating item definition be
   *                                   displayed using a color gradient when viewing the survey
   *                                   result
   */
  public void setDisplayRatingUsingGradient(boolean displayRatingUsingGradient)
  {
    this.displayRatingUsingGradient = displayRatingUsingGradient;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * definition this survey group rating item definition is associated with.
   *
   * @param groupDefinitionId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                          survey group definition this survey group rating item definition is
   *                          associated with
   */
  public void setGroupDefinitionId(UUID groupDefinitionId)
  {
    this.groupDefinitionId = groupDefinitionId;
  }

  /**
   * Set the name of the survey group rating item definition.
   *
   * @param name the name of the survey group rating item definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Set the type of survey group rating item.
   *
   * @param ratingType the type of survey group rating item
   */
  public void setRatingType(SurveyGroupRatingItemType ratingType)
  {
    this.ratingType = ratingType;
  }

  /**
   * Returns the String representation of the survey group rating item definition.
   *
   * @return the String representation of the survey group rating item definition
   */
  @Override
  public String toString()
  {
    return String.format(
        "SurveyDefinitionGroupRatingItem {id=\"%s\", name=\"%s\", ratingType=\"%s\"", getId(),
        getName(), getRatingType().description());
  }
}
