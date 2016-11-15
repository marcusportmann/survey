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

//~--- JDK imports ------------------------------------------------------------

import javax.enterprise.inject.Vetoed;
import javax.persistence.*;
import java.io.Serializable;
import java.util.UUID;

/**
 * The <code>SurveyDefinition</code> class implements the Survey Definition entity, which represents
 * a survey audience member i.e. an external person who will complete a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_AUDIENCE_MEMBERS")
@Vetoed
public class SurveyAudienceMember
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey audience member.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The first name(s) for the survey audience member.
   */
  @Column(name = "FIRST_NAME", nullable = false)
  private String firstName;

  /**
   * The last name for the survey audience member.
   */
  @Column(name = "LAST_NAME", nullable = false)
  private String lastName;

  /**
   * The e-mail address for the survey audience member.
   */
  @Column(name = "EMAIL", nullable = false)
  private String email;

  /**
   * The survey audience this survey audience member is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_AUDIENCE_ID", referencedColumnName = "ID")
  protected SurveyAudience audience;

  /**
   * Constructs a new <code>SurveyAudienceMember</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyAudienceMember() {}

  /**
   * Constructs a new <code>SurveyAudienceMember</code>.
   *
   * @param id        the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                  audience member
   * @param audience  the survey audience the survey audience member is associated with
   * @param firstName the first name(s) for the survey audience member
   * @param lastName  the last name for the survey audience member
   * @param email     the e-mail address for the survey audience member
   */
  public SurveyAudienceMember(UUID id, SurveyAudience audience, String firstName, String lastName,
      String email)
  {
    this.id = id;
    this.audience = audience;
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email;
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

    SurveyAudienceMember other = (SurveyAudienceMember) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the e-mail address for the survey audience member.
   *
   * @return the e-mail address for the survey audience member
   */
  public String getEmail()
  {
    return email;
  }

  /**
   * Returns the first name(s) for the survey audience member.
   *
   * @return the first name(s) for the survey audience member
   */
  public String getFirstName()
  {
    return firstName;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey audience
   * member.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey audience
   *         member
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the last name for the survey audience member.
   *
   * @return the last name for the survey audience member
   */
  public String getLastName()
  {
    return lastName;
  }

  /**
   * Set the e-mail address for the survey audience member.
   *
   * @param email the e-mail address for the survey audience member
   */
  public void setEmail(String email)
  {
    this.email = email;
  }

  /**
   * Set the first name(s) for the survey audience member.
   *
   * @param firstName the first name(s) for the survey audience member
   */
  public void setFirstName(String firstName)
  {
    this.firstName = firstName;
  }

  /**
   * Set the last name for the survey audience member.
   *
   * @param lastName the last name for the survey audience member
   */
  public void setLastName(String lastName)
  {
    this.lastName = lastName;
  }

  /**
   * Returns the String representation of the survey audience member.
   *
   * @return the String representation of the survey audience member
   */
  @Override
  public String toString()
  {
    String buffer = "SurveyAudienceMember {" + "id=\"" + getId() + "\", " + "firstName=\""
        + getFirstName() + "\", " + "lastName=\"" + getLastName() + "\", " + "email=\""
        + getEmail() + "\"" + "}";

    return buffer;
  }
}
