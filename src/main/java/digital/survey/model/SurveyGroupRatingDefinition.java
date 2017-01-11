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
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyGroupRatingDefinition</code> class implements the Survey Group Rating Definition
 * entity, which represents the definition for a rating that can be captured for each member of a
 * group of entities.
 *
 * @author Marcus Portmann
 */
@JsonPropertyOrder({ "id", "name", "ratingType" })
public class SurveyGroupRatingDefinition
  implements Serializable
{
  private static final long serialVersionUID = 1000000;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey group rating
   * definition.
   */
  @JsonProperty
  private UUID id;

  /**
   * The name of the survey group rating definition.
   */
  @JsonProperty
  private String name;

  /**
   * The type of survey group rating.
   */
  @JsonProperty
  private SurveyGroupRatingType ratingType;

  /**
   * Constructs a new <code>SurveyDefinitionGroupRating</code>.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingDefinition() {}

  /**
   * Constructs a new <code>SurveyDefinitionGroupRating</code>.
   *
   * @param name       the name of the survey group rating definition
   * @param ratingType the type of survey group rating
   */
  public SurveyGroupRatingDefinition(String name, SurveyGroupRatingType ratingType)
  {
    this.id = UUID.randomUUID();
    this.name = name;
    this.ratingType = ratingType;
  }

  /**
   * Retrieve the survey group rating definition from the list of survey item definitions.
   *
   * @param itemDefinitions the survey item definitions
   * @param id              the Universally Unique Identifier (UUID) used to uniquely identify the
   *                        survey group rating definition
   *
   * @return the survey group rating definition or <code>null</code> if the survey group rating
   *         definition could not be found
   */
  public static SurveyGroupRatingDefinition getGroupRatingDefinition(
      List<SurveyItemDefinition> itemDefinitions, UUID id)
  {
    for (SurveyItemDefinition itemDefinition : itemDefinitions)
    {
      if (itemDefinition instanceof SurveyGroupRatingsDefinition)
      {
        SurveyGroupRatingsDefinition groupRatingsDefinition =
            (SurveyGroupRatingsDefinition) itemDefinition;

        for (SurveyGroupRatingDefinition groupRatingDefinition :
            groupRatingsDefinition.getGroupRatingDefinitions())
        {
          if (groupRatingDefinition.getId().equals(id))
          {
            return groupRatingDefinition;
          }
        }
      }
      else if (itemDefinition instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) itemDefinition;

        SurveyGroupRatingDefinition groupRatingDefinition =
            sectionDefinition.getGroupRatingDefinition(id);

        if (groupRatingDefinition != null)
        {
          return groupRatingDefinition;
        }
      }
    }

    return null;
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

    SurveyGroupRatingDefinition other = (SurveyGroupRatingDefinition) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   * rating definition.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *         rating definition
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey group rating definition.
   *
   * @return the name of the survey group rating definition
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the type of survey group rating.
   *
   * @return the type of survey group rating
   */
  public SurveyGroupRatingType getRatingType()
  {
    return ratingType;
  }

  /**
   * Set the name of the survey group rating definition.
   *
   * @param name the name of the survey group rating definition
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Set the type of survey group rating.
   *
   * @param ratingType the type of survey group rating
   */
  public void setRatingType(SurveyGroupRatingType ratingType)
  {
    this.ratingType = ratingType;
  }

  /**
   * Returns the String representation of the survey group rating definition.
   *
   * @return the String representation of the survey group rating definition
   */
  @Override
  public String toString()
  {
    return String.format("SurveyGroupRatingDefinition {id=\"%s\", name=\"%s\", ratingType=\"%s\"}",
        getId(), getName(), getRatingType().description());
  }
}
