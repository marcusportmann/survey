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

import guru.mmp.common.util.DateUtil;

import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyRequest</code> class implements the Survey Request entity, which represents
 * a request that was requested to a person asking them to complete a survey
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_REQUESTS")
@SqlResultSetMapping(name = "SurveyRequestToSurveyResponseMapping",
    classes = { @ConstructorResult(targetClass = SurveyRequestToSurveyResponseMapping.class,
        columns = { @ColumnResult(name = "REQUEST_ID", type = UUID.class) ,
            @ColumnResult(name = "REQUESTED", type = Date.class) ,
            @ColumnResult(name = "RESPONSE_ID", type = UUID.class) ,
            @ColumnResult(name = "RESPONDED", type = Date.class) }) })
public class SurveyRequest
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey request.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The first name(s) for the person who was requested to complete the survey.
   */
  @Column(name = "FIRST_NAME", nullable = false)
  private String firstName;

  /**
   * The last name for the person who was requested to complete the survey.
   */
  @Column(name = "LAST_NAME", nullable = false)
  private String lastName;

  /**
   * The e-mail address for the person who was requested to complete the survey.
   */
  @Column(name = "EMAIL", nullable = false)
  private String email;

  /**
   * The date and time the request to complete the survey was last sent.
   */
  @Column(name = "REQUESTED", nullable = false)
  private Date requested;

  /**
   * The survey instance this survey request is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_INSTANCE_ID")
  private SurveyInstance instance;

  /**
   * The status of the survey request.
   */
  @Column(name = "STATUS", nullable = false)
  @Convert(converter = SurveyRequestStatusConverter.class)
  private SurveyRequestStatus status;

  /**
   * Constructs a new <code>SurveyRequest</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyRequest() {}

  /**
   * Constructs a new <code>SurveyRequest</code>.
   *
   * @param instance  the survey instance this survey request is associated with
   * @param firstName the first name(s) for the person who was requested to complete the survey
   * @param lastName  the last name for the person who was requested to complete the survey
   * @param email     the e-mail address for the person who was requested to complete the survey
   */
  public SurveyRequest(SurveyInstance instance, String firstName, String lastName, String email)
  {
    this(UUID.randomUUID(), instance, firstName, lastName, email);
  }

  /**
   * Constructs a new <code>SurveyRequest</code>.
   *
   * @param id        the Universally Unique Identifier (UUID) used to uniquely identify the survey
   *                  request
   * @param instance  the survey instance this survey request is associated with
   * @param firstName the first name(s) for the person who was requested to complete the survey
   * @param lastName  the last name for the person who was requested to complete the survey
   * @param email     the e-mail address for the person who was requested to complete the survey
   */
  public SurveyRequest(UUID id, SurveyInstance instance, String firstName, String lastName,
      String email)
  {
    this.id = id;
    this.status = SurveyRequestStatus.QUEUED_FOR_SENDING;
    this.instance = instance;
    this.firstName = firstName;
    this.lastName = lastName;
    this.email = email.toLowerCase();
    this.requested = new Date();
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

    SurveyRequest other = (SurveyRequest) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the e-mail address for the person who was requested to complete the survey.
   *
   * @return the e-mail address for the person who was requested to complete the survey
   */
  public String getEmail()
  {
    return email;
  }

  /**
   * Returns the first name(s) for the person who was requested to complete the survey.
   *
   * @return the first name(s) for the person who was requested to complete the survey
   */
  public String getFirstName()
  {
    return firstName;
  }

  /**
   * Returns the full name for the person who was requested to complete the survey.
   *
   * @return the full name for the person who was requested to complete the survey
   */

  public String getFullName()
  {
    return firstName + " " + lastName;
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey request.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the survey instance this survey request is associated with.
   *
   * @return the survey instance this survey request is associated with
   */
  public SurveyInstance getInstance()
  {
    return instance;
  }

  /**
   * Returns the last name for the person who was requested to complete the survey.
   *
   * @return the last name for the person who was requested to complete the survey
   */
  public String getLastName()
  {
    return lastName;
  }

  /**
   * Returns the date and time the request to complete the survey was last sent.
   *
   * @return the date and time the request to complete the survey was last sent
   */
  public Date getRequested()
  {
    return requested;
  }

  /**
   * Returns the date and time the request to complete the survey was last sent as a
   * <code>String</code>.
   *
   * @return the date and time the request to complete the survey was last sent as a
   *         <code>String</code>.
   */
  public String getRequestedAsString()
  {
    return DateUtil.getYYYYMMDDWithTimeFormat().format(requested);
  }

  /**
   * Returns the status of the survey request.
   *
   * @return the status of the survey request
   */
  public SurveyRequestStatus getStatus()
  {
    return status;
  }

  /**
   * Set the e-mail address for the person who was requested to complete the survey.
   *
   * @param email the e-mail address for the person who was requested to complete the survey
   */
  public void setEmail(String email)
  {
    this.email = email;
  }

  /**
   * Set the first name(s) for the person who was requested to complete the survey.
   *
   * @param firstName the first name(s) for the person who was requested to complete the survey
   */
  public void setFirstName(String firstName)
  {
    this.firstName = firstName;
  }

  /**
   * Set the last name for the person who was requested to complete the survey.
   *
   * @param lastName the last name for the person who was requested to complete the survey
   */
  public void setLastName(String lastName)
  {
    this.lastName = lastName;
  }

  /**
   * Set the date and time the request to complete the survey was last sent.
   *
   * @param requested the date and time the request to complete the survey was last sent
   */
  public void setRequested(Date requested)
  {
    this.requested = requested;
  }

  /**
   * Set the status of the survey request.
   *
   * @param status the status of the survey request
   */
  public void setStatus(SurveyRequestStatus status)
  {
    this.status = status;
  }

  /**
   * Returns the String representation of the survey request.
   *
   * @return the String representation of the survey request
   */
  @Override
  public String toString()
  {
    return String.format(
        "SurveyRequest {id=\"%s\", firstName=\"%s\", lastName=\"%s\", email=\"%s\", requested=\"%s\"}",
        getId(), getFirstName(), getLastName(), getEmail(), DateUtil.getYYYYMMDDWithTimeFormat()
        .format(getRequested()));
  }
}
