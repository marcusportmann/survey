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
 * The <code>SurveyTemplateGroupMember</code> class implements the Survey Template Group Member
 * entity, which represents an entity who is a member of a survey template group, e.g. a member of
 * a team, that is associated with a survey template
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_TEMPLATE_GROUP_MEMBERS")
public class SurveyTemplateGroupMember
{
  /**
   * The Universally Unique Identifier (UUID) used  to uniquely identify the survey template group
   * member.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The Universally Unique Identifier (UUID) used to uniquely  identify the survey template group
   * this survey template group member is associated with.
   */
  @Column(name = "TEMPLATE_GROUP_ID", nullable = false, insertable = false, updatable = false)
  private UUID templateGroupId;

  /**
   * The survey template group this survey template group member is associated with.
   */
  @ManyToOne
  @JoinColumn(name = "TEMPLATE_GROUP_ID", referencedColumnName = "ID")
  private SurveyTemplateGroup group;

  /**
   * The name of the survey template group member.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * Returns the survey template group this survey template group member is associated with.
   *
   * @return the survey template group this survey template group member is associated with
   */
  public SurveyTemplateGroup getGroup()
  {
    return group;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used  to uniquely identify the survey
   * template group member.
   *
   * @return the Universally Unique Identifier (UUID) used  to uniquely identify the survey
   *         template group member
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the name of the survey template group member.
   *
   * @return the name of the survey template group member
   */
  public String getName()
  {
    return name;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely  identify the survey template
   * group this survey template group member is associated with.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely  identify the survey template
   *         group this survey template group member is associated with
   */
  public UUID getTemplateGroupId()
  {
    return templateGroupId;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used  to uniquely identify the survey template
   * group member.
   *
   * @param id the Universally Unique Identifier (UUID) used  to uniquely identify the survey
   *           template group member
   */
  public void setId(UUID id)
  {
    this.id = id;
  }

  /**
   * Set the name of the survey template group member.
   *
   * @param name the name of the survey template group member
   */
  public void setName(String name)
  {
    this.name = name;
  }

  /**
   * Set the Universally Unique Identifier (UUID) used to uniquely  identify the survey template
   * group this survey template group member is associated with.
   *
   * @param templateGroupId the Universally Unique Identifier (UUID) used to uniquely  identify the
   *                        survey template group this survey template group member is associated
   *                        with
   */
  public void setTemplateGroupId(UUID templateGroupId)
  {
    this.templateGroupId = templateGroupId;
  }
}
