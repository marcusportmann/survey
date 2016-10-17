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

package guru.mmp.survey.model;

//~--- JDK imports ------------------------------------------------------------

import javax.persistence.*;
import java.util.UUID;

/**
 * The <code>SurveyGroupRatingItemDefinition</code> class implements the Survey Group Rating Item
 * Definition entity, which represents represents the definition for a group rating item that forms
 * part of a survey definition.
 *
 * @author Marcus Portmann
 */
@Entity
@IdClass(VersionedId.class)
@Table(schema = "SURVEY", name = "SURVEY_GROUP_RATING_ITEM_DEFINITIONS")
public class SurveyGroupRatingItemDefinition
{
  /**
   * The Universally Unique Identifier (UUID) used, along with the version of the survey group
   * rating item definition, to uniquely identify the survey group rating item definition.
   */
  @Id
  private UUID id;

  /**
   * The version of the survey group rating item definition.
   */
  @Id
  private int version;

  /**
   * The name of the survey group rating item definition.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The survey definition this survey group definition is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumns({ @JoinColumn(name = "SURVEY_DEFINITION_ID", referencedColumnName = "ID") ,
      @JoinColumn(name = "SURVEY_DEFINITION_VERSION", referencedColumnName = "VERSION") })
  private SurveyDefinition surveyDefinition;

  /**
   * The survey group definition this survey group rating item definition is associated with.
   */
  @ManyToOne(cascade = { CascadeType.MERGE })
  @JoinColumns({ @JoinColumn(name = "SURVEY_GROUP_DEFINITION_ID", referencedColumnName = "ID") ,
      @JoinColumn(name = "SURVEY_GROUP_DEFINITION_VERSION", referencedColumnName = "VERSION") })
  private SurveyGroupDefinition surveyGroupDefinition;

  /**
   * The numeric code giving the type of survey group rating item e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   */
  @Column(name = "RATING_TYPE", nullable = false)
  @Convert(converter = SurveyGroupRatingItemTypeConverter.class)
  private SurveyGroupRatingItemType ratingType;

  /**
   * Constructs a new <code>SurveyDefinitionGroupRatingItem</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyGroupRatingItemDefinition() {}

  /**
   * Constructs a new <code>SurveyDefinitionGroupRatingItem</code>.
   *
   * @param id                    the Universally Unique Identifier (UUID) used, along with the
   *                              version of the survey group rating item definition, to uniquely
   *                              identify the survey group rating item definition
   * @param version               the version of the survey group rating item definition
   * @param name                  the name of the survey group rating item definition
   * @param surveyGroupDefinition the survey group definition this survey group rating item
   *                              definition is associated with
   * @param ratingType            the numeric code giving the type of survey group rating item
   *                              e.g. 1 = Percentage, 2 = Yes/No/NA, etc
   */
  public SurveyGroupRatingItemDefinition(UUID id, int version, String name,
      SurveyGroupDefinition surveyGroupDefinition, SurveyGroupRatingItemType ratingType)
  {
    this.id = id;
    this.version = version;
    this.name = name;
    this.surveyGroupDefinition = surveyGroupDefinition;
    this.ratingType = ratingType;
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
   * Returns the Universally Unique Identifier (UUID) used, along with the version of the survey
   * group rating item definition, to uniquely identify the survey group rating item definition.
   *
   * @return the Universally Unique Identifier (UUID) used, along with the version of the survey
   *         group rating item definition, to uniquely identify the survey group rating item
   *         definition
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
   * Returns the numeric code giving the type of survey group rating item e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   *
   * @return the numeric code giving the type of survey group rating item e.g. 1 = Percentage,
   *         2 = Yes/No/NA, etc
   */
  public SurveyGroupRatingItemType getRatingType()
  {
    return ratingType;
  }

  /**
   * Returns the survey group definition this survey group rating item definition is associated with.
   *
   * @return the survey group definition this survey group rating item definition is associated with
   */
  public SurveyGroupDefinition getSurveyGroupDefinition()
  {
    return surveyGroupDefinition;
  }

  /**
   * Return the version of the survey group rating item definition.
   *
   * @return the version of the survey group rating item definition
   */
  public int getVersion()
  {
    return version;
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
   * Set the numeric code giving the type of survey group rating item e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   *
   * @param ratingType the numeric code giving the type of survey group rating item
   *                   e.g. 1 = Percentage, 2 = Yes/No/NA, etc
   */
  public void setRatingType(SurveyGroupRatingItemType ratingType)
  {
    this.ratingType = ratingType;
  }

  /**
   * Set the survey group definition this survey group rating item definition is associated with.
   *
   * @param surveyGroupDefinition the survey group definition this survey group rating item
   *                              definition is associated with
   */
  public void setSurveyGroupDefinition(SurveyGroupDefinition surveyGroupDefinition)
  {
    this.surveyGroupDefinition = surveyGroupDefinition;
  }

  /**
   * Returns the String representation of the survey group rating item definition.
   *
   * @return the String representation of the survey group rating item definition
   */
  @Override
  public String toString()
  {
    String buffer = "SurveyDefinitionGroupRatingItem {" + "id=\"" + getId() + "\", " + "version=\""
        + getVersion() + "\", " + "name=\"" + getName() + "\", " + "ratingType=\""
        + getRatingType().description() + "\"" + "}";

    return buffer;
  }

  /**
   * Set the survey definition this survey group rating item definition is associated with.
   *
   * @param surveyDefinition the survey definition this survey group rating item definition is
   *                         associated with
   */
  protected void setSurveyDefinition(SurveyDefinition surveyDefinition)
  {
    this.surveyDefinition = surveyDefinition;
  }
}
