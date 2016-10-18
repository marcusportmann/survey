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
import java.io.Serializable;
import java.util.UUID;

/**
 * The <code>SurveyRequest</code> class implements the Survey Request entity, which represents
 * a request that was sent to a person asking them to complete a survey
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_REQUESTS")
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
   * The survey instance this survey request is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_INSTANCE_ID")
  private SurveyInstance surveyInstance;

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
   * @param id             the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       survey request
   * @param surveyInstance the survey instance this survey request is associated with
   */
  public SurveyRequest(UUID id, SurveyInstance surveyInstance)
  {
    this.id = id;
    this.surveyInstance = surveyInstance;
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
   * Returns the Universally Unique Identifier (UUID) used to uniquely identify the survey request.
   *
   * @return the Universally Unique Identifier (UUID) used to uniquely identify the survey request
   */
  public UUID getId()
  {
    return id;
  }

  /**
   * Returns the String representation of the survey request.
   *
   * @return the String representation of the survey request
   */
  @Override
  public String toString()
  {
    return String.format("SurveyRequest {id=\"%s\"}", getId());
  }
}
