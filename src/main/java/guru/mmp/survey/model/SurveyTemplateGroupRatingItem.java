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
 * The <code>SurveyTemplateGroupRatingItem</code> class implements the Survey Template Group Rating
 * Item entity, which represents represents a group rating item that forms part of a template for a
 * survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_TEMPLATE_GROUP_RATING_ITEMS")
public class SurveyTemplateGroupRatingItem
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey template group
   * rating item.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey template this
   * survey template group rating item is associated with.
   */
  @Column(name = "TEMPLATE_ID", nullable = false)
  private UUID templateId;

  /**
   * The name of the survey template group rating item.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey template group
   * this survey template group rating item is associated with.
   */
  @Column(name = "TEMPLATE_GROUP_ID", nullable = false)
  private UUID templateGroupId;

  /**
   * The numeric code giving the type of survey template group rating e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   */
  @Convert(converter = SurveyTemplateGroupRatingTypeConverter.class)
  private SurveyTemplateGroupRatingType ratingType;

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group rating item.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   *         group rating item
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey template group rating item.
   *
   * @return the name of the survey template group rating item
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the numeric code giving the type of survey template group rating e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   *
   * @return the numeric code giving the type of survey template group rating e.g. 1 = Percentage,
   *         2 = Yes/No/NA, etc
   */
  public SurveyTemplateGroupRatingType getRatingType()
  {
    return ratingType;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group this survey template group rating item is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   *         group this survey template group rating item is associated with
   */
  public UUID getTemplateGroupId()
  {
    return templateGroupId;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * this survey template group rating item is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   *         this survey template group rating item is associated with
   */
  public UUID getTemplateId()
  {
    return templateId;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group rating item.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *           template group rating item
   */
  public void setId(UUID id)
  {
    this.id = id;
  }

  /**
   * Set the name of the survey template group rating item.
   *
   * @param name the name of the survey template group rating item
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Set the numeric code giving the type of survey template group rating e.g. 1 = Percentage,
   * 2 = Yes/No/NA, etc.
   *
   * @param ratingType the numeric code giving the type of survey template group rating
   *                   e.g. 1 = Percentage, 2 = Yes/No/NA, etc
   */
  public void setRatingType(SurveyTemplateGroupRatingType ratingType)
  {
    this.ratingType = ratingType;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * group this survey template group rating item is associated with.
   *
   * @param templateGroupId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                        survey template group this survey template group rating item is
   *                        associated with
   */
  public void setTemplateGroupId(UUID templateGroupId)
  {
    this.templateGroupId = templateGroupId;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely identify the survey template
   * this survey template group rating item is associated with.
   *
   * @param templateId the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                   template this survey template group rating item is associated with
   */
  public void setTemplateId(UUID templateId)
  {
    this.templateId = templateId;
  }
}
