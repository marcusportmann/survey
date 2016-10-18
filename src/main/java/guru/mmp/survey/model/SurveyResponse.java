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

//~--- non-JDK imports --------------------------------------------------------

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;

import javax.persistence.*;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

//~--- JDK imports ------------------------------------------------------------

/**
 * The <code>SurveyResponse</code> class implements the Survey Response entity, which represents
 * a user's response to a survey.
 *
 * @author Marcus Portmann
 */
@Entity
@Table(schema = "SURVEY", name = "SURVEY_RESPONSES")
@Access(AccessType.FIELD)
public class SurveyResponse
  implements Serializable
{
  /**
   * The Universally Unique Identifier (UUID) used to uniquely identify the survey response.
   */
  @Id
  @Column(name = "ID", nullable = false)
  @JsonProperty
  private UUID id;

  /**
   * The survey instance this survey response is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_INSTANCE_ID")
  @JsonIgnore
  private SurveyInstance surveyInstance;

  /**
   * The optional survey request this survey response is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_REQUEST_ID")
  @JsonIgnore
  private SurveyRequest surveyRequest;

  /**
   * The survey group rating item responses that are associated with the survey response.
   */
  @JsonProperty
  @Transient
  private List<SurveyGroupRatingItemResponse> groupRatingItemResponses;

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * Default constructor required for JPA.
   */
  @SuppressWarnings("unused")
  SurveyResponse() {}

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param surveyInstance the survey instance this survey response is associated with
   */
  public SurveyResponse(SurveyInstance surveyInstance)
  {
    this(surveyInstance, null);
  }

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param surveyInstance the survey instance this survey response is associated with
   * @param surveyRequest  the optional survey request this survey response is associated with
   */
  public SurveyResponse(SurveyInstance surveyInstance, SurveyRequest surveyRequest)
  {
    this.id = UUID.randomUUID();
    this.surveyInstance = surveyInstance;
    this.surveyRequest = surveyRequest;
    this.groupRatingItemResponses = new ArrayList<>();

    for (SurveyGroupRatingItemDefinition groupRatingItemDefinition :
        surveyInstance.getSurveyDefinition().getGroupRatingItemDefinitions())
    {
      SurveyGroupDefinition groupDefinition = surveyInstance.getSurveyDefinition()
          .getGroupDefinition(groupRatingItemDefinition.getGroupDefinitionId());

      for (SurveyGroupMemberDefinition groupMemberDefinition :
          groupDefinition.getGroupMemberDefinitions())
      {
        groupRatingItemResponses.add(new SurveyGroupRatingItemResponse(groupRatingItemDefinition,
            groupMemberDefinition));
      }
    }
  }

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param id             the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       survey response
   * @param surveyInstance the survey instance this survey response is associated with
   */
  public SurveyResponse(UUID id, SurveyInstance surveyInstance)
  {
    this.id = id;
    this.surveyInstance = surveyInstance;
  }

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param id             the Universally Unique Identifier (UUID) used to uniquely identify the
   *                       survey response
   * @param surveyInstance the survey instance this survey response is associated with
   * @param surveyRequest  the optional survey request this survey response is associated with
   */
  public SurveyResponse(UUID id, SurveyInstance surveyInstance, SurveyRequest surveyRequest)
  {
    this.id = id;
    this.surveyInstance = surveyInstance;
    this.surveyRequest = surveyRequest;
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

    SurveyResponse other = (SurveyResponse) obj;

    return id.equals(other.id);
  }

  /**
   * Returns the JSON data for the survey response.
   *
   * @return the JSON data for the survey response
   */
  @Column(name = "DATA", nullable = false)
  @Access(AccessType.PROPERTY)
  @JsonIgnore
  public String getData()
  {
    try
    {
      return new ObjectMapper().writeValueAsString(this);
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to generate the JSON data for the survey response", e);
    }
  }

  /**
   * Retrieve the survey group rating item response.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating item response
   *
   * @return the survey group rating item response or <code>null</code> if the survey group rating
   *         item response could not be found
   */
  public SurveyGroupRatingItemResponse getGroupRatingItemResponse(UUID id)
  {
    for (SurveyGroupRatingItemResponse groupRatingItemResponse : groupRatingItemResponses)
    {
      if (groupRatingItemResponse.getId().equals(id))
      {
        return groupRatingItemResponse;
      }
    }

    return null;
  }

  /**
   * Returns the survey group rating item responses that are associated with the survey response.
   *
   * @return the survey group rating item responses that are associated with the survey response
   */
  public List<SurveyGroupRatingItemResponse> getGroupRatingItemResponses()
  {
    return groupRatingItemResponses;
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
   * Set the JSON data for the survey response.
   *
   * @param data the JSON data for the survey response
   */
  public void setData(String data)
  {
    try
    {
      new ObjectMapper().readerForUpdating(this).readValue(data);
    }
    catch (Throwable e)
    {
      throw new RuntimeException("Failed to populate the survey response using the JSON data", e);
    }
  }

  /**
   * Returns the String representation of the survey response.
   *
   * @return the String representation of the survey response
   */
  @Override
  public String toString()
  {
    return String.format("SurveyResponse {id=\"%s\"}", getId());
  }
}
