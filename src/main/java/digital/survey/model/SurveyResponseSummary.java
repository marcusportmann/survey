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

import javax.enterprise.inject.Vetoed;
import javax.persistence.*;
import java.io.Serializable;
import java.util.Date;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyResponseSummary</code> class implements the Survey Response Summary entity,
 * which represents a summary for a user's response to a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_RESPONSES")
@Vetoed
public class SurveyResponseSummary
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   */
  @Id
  @Column(name = "ID", nullable = false)
  private UUID id;

  /**
   * The survey instance this survey response is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_INSTANCE_ID")
  private SurveyInstance instance;

  /**
   * The optional survey request this survey response is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_REQUEST_ID")
  private SurveyRequest request;

  /**
   * The date and time the survey response was received.
   */
  @Column(name = "RESPONDED", nullable = false)
  private Date responded;

  /**
   * Constructs a new <code>SurveyResponseSummary</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyResponseSummary() {}

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

    SurveyResponseSummary other = (SurveyResponseSummary) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey response
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * The name for the survey response.
   *
   * @return the name for the survey response
   */
  public String getName()
  {
    if (request == null)
    {
      return String.format("Anonymous on %s", DateUtil.getYYYYMMDDFormat().format(getResponded()));
    }
    else
    {
      return request.getFullName();
    }
  }

  /**
   * Returns the optional survey request this survey response is associated with.
   *
   * @return the optional survey request this survey response is associated with
   */
  public SurveyRequest getRequest()
  {
    return request;
  }

  /**
   * Returns the date and time the survey response was received.
   *
   * @return the date and time the survey response was received
   */
  public Date getResponded()
  {
    return responded;
  }

  /**
   * Returns the date and time the survey response was received as a <code>String</code>.
   *
   * @return the date and time the survey response was received as a <code>String</code>
   */
  public String getRespondedAsString()
  {
    return DateUtil.getYYYYMMDDWithTimeFormat().format(responded);
  }

  /**
   * Returns the String representation of the survey response.
   *
   * @return the String representation of the survey response
   */
  @Override
  public String toString()
  {
    return String.format("SurveyResponseSummary {id=\"%s\", name=\"%s\"}", getId(), getName());
  }
}
