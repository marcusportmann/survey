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
   * The name of the survey template group member.
   */
  @Column(name = "NAME", nullable = false)
  private String name;

  /**
   * The survey template group this survey template group member is associated with.
   */
  @ManyToOne
  @JoinColumn(name = "SURVEY_TEMPLATE_GROUP_ID", nullable = false, updatable = false)
  private SurveyTemplateGroup group;

  /**
   * Constructs a new <code>SurveyTemplateGroupMember</code>.
   */
  SurveyTemplateGroupMember() {}

  /**
   * Constructs a new <code>SurveyTemplateGroupMember</code>.
   *
   * @param id   the Universally Unique Identifier (UUID) used  to uniquely identify the survey
   *             template group member
   * @param name the name of the survey template group member
   */
  public SurveyTemplateGroupMember(UUID id, String name)
  {
    this.id = id;
    this.name = name;
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

    SurveyTemplateGroupMember other = (SurveyTemplateGroupMember) obj;

    return id.equals(other.id);
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
   * Returns the String representation of the survey template group member.
   *
   * @return the String representation of the survey template group member
   */
  @Override
  public String toString()
  {
    StringBuilder buffer = new StringBuilder();

    buffer.append("SurveyTemplateGroupMember {");
    buffer.append("id=\"").append(getId()).append("\", ");
    buffer.append("name=\"").append(getName()).append("\"");
    buffer.append("}");

    return buffer.toString();
  }

  /**
   * Set the survey template group this survey template group member is associated with.
   *
   * @param group the survey template group this survey template group member is associated with
   */
  protected void setGroup(SurveyTemplateGroup group)
  {
    this.group = group;
  }
}
