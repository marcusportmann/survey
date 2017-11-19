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

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.databind.ObjectMapper;
import guru.mmp.common.util.DateUtil;

import javax.persistence.*;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.Date;
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
  private static final long serialVersionUID = 1000000;

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
  private SurveyInstance instance;

  /**
   * The survey item responses that are associated with the survey response.
   */
  @JsonProperty
  @Transient
  private List<SurveyItemResponse> itemResponses;

  /**
   * The optional survey request this survey response is associated with.
   */
  @SuppressWarnings("unused")
  @ManyToOne
  @JoinColumn(name = "SURVEY_REQUEST_ID")
  @JsonIgnore
  private SurveyRequest request;

  /**
   * The date and time the survey response was received.
   */
  @Column(name = "RESPONDED", nullable = false)
  @JsonIgnore
  private Date responded;

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
   * @param instance the survey instance this survey response is associated with
   */
  public SurveyResponse(SurveyInstance instance)
  {
    this(instance, null);
  }

  /**
   * Constructs a new <code>SurveyResponse</code>.
   *
   * @param instance the survey instance this survey response is associated with
   * @param request  the optional survey request this survey response is associated with
   */
  public SurveyResponse(SurveyInstance instance, SurveyRequest request)
  {
    this.id = UUID.randomUUID();
    this.instance = instance;
    this.request = request;
    this.responded = new Date();
    this.itemResponses = new ArrayList<>();

    initItemResponses(instance.getDefinition().getItemDefinitions());
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
   * Retrieve the survey group rating response.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey group
   *           rating response
   *
   * @return the survey group rating response or <code>null</code> if the survey group rating
   *         response could not be found
   */
  public SurveyGroupRatingResponse getGroupRatingResponse(UUID id)
  {
    for (SurveyItemResponse itemResponse : itemResponses)
    {
      if (itemResponse instanceof SurveyGroupRatingResponse)
      {
        SurveyGroupRatingResponse groupRatingResponse = (SurveyGroupRatingResponse) itemResponse;

        if (groupRatingResponse.getId().equals(id))
        {
          return groupRatingResponse;
        }
      }
    }

    return null;
  }

  /**
   * Retrieve the survey group rating response.
   *
   * @param groupRatingsDefinitionId the Universally Unique Identifier (UUID) used to uniquely
   *                                 identify the survey group rating definition this survey group
   *                                 rating response is associated with
   * @param groupRatingDefinitionId  the Universally Unique Identifier (UUID) used to uniquely
   *                                 identify the survey group rating definition this survey group
   *                                 rating response is associated with
   * @param groupMemberDefinitionId  the Universally Unique Identifier (UUID) used to uniquely
   *                                 identify the survey group member definition this survey group
   *                                 rating response is associated with
   *
   * @return the survey group rating response or <code>null</code> if the survey group rating
   *         response could not be found
   */
  public SurveyGroupRatingResponse getGroupRatingResponseForDefinition(
      UUID groupRatingsDefinitionId, UUID groupRatingDefinitionId, UUID groupMemberDefinitionId)
  {
    for (SurveyItemResponse itemResponse : itemResponses)
    {
      if (itemResponse instanceof SurveyGroupRatingResponse)
      {
        SurveyGroupRatingResponse groupRatingResponse = (SurveyGroupRatingResponse) itemResponse;

        if ((groupRatingResponse.getGroupRatingsDefinitionId().equals(groupRatingsDefinitionId))
            && (groupRatingResponse.getGroupRatingDefinitionId().equals(groupRatingDefinitionId))
            && (groupRatingResponse.getGroupMemberDefinitionId().equals(groupMemberDefinitionId)))
        {
          return groupRatingResponse;
        }
      }
    }

    return null;
  }

  /**
   * Returns the survey group rating responses that are associated with the survey response.
   *
   * @return the survey group rating responses that are associated with the survey response
   */
  @JsonIgnore
  public List<SurveyGroupRatingResponse> getGroupRatingResponses()
  {
    List<SurveyGroupRatingResponse> groupRatingResponses = new ArrayList<>();

    for (SurveyItemResponse itemResponse : itemResponses)
    {
      if (itemResponse instanceof SurveyGroupRatingResponse)
      {
        groupRatingResponses.add(((SurveyGroupRatingResponse) itemResponse));
      }
    }

    return groupRatingResponses;
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
   * Returns the survey instance this survey response is associated with.
   *
   * @return the survey instance this survey response is associated with
   */
  public SurveyInstance getInstance()
  {
    return instance;
  }

  /**
   * Returns the survey item responses that are associated with the survey response.
   *
   * @return the survey item responses that are associated with the survey response
   */
  public List<SurveyItemResponse> getItemResponses()
  {
    return itemResponses;
  }

  /**
   * The name for the survey response.
   *
   * @return the name for the survey response
   */
  @JsonIgnore
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
  @JsonIgnore
  public String getRespondedAsString()
  {
    return DateUtil.getYYYYMMDDWithTimeFormat().format(responded);
  }

  /**
   * Retrieve the survey text response.
   *
   * @param id the Universally Unique Identifier (UUID) used to uniquely identify the survey text
   *           response
   *
   * @return the survey text response or <code>null</code> if the survey text response could not be
   *         found
   */
  public SurveyTextResponse getTextResponse(UUID id)
  {
    for (SurveyItemResponse itemResponse : itemResponses)
    {
      if (itemResponse instanceof SurveyTextResponse)
      {
        SurveyTextResponse textResponse = (SurveyTextResponse) itemResponse;

        if (textResponse.getId().equals(id))
        {
          return textResponse;
        }
      }
    }

    return null;
  }

  /**
   * Retrieve the survey text response.
   *
   * @param textDefinitionId the Universally Unique Identifier (UUID) used to uniquely identify the
   *                         survey text definition this survey text response is associated with
   *
   * @return the survey text response or <code>null</code> if the survey text response could not be
   *         found
   */
  public SurveyTextResponse getTextResponseForDefinition(UUID textDefinitionId)
  {
    for (SurveyItemResponse itemResponse : itemResponses)
    {
      if (itemResponse instanceof SurveyTextResponse)
      {
        SurveyTextResponse textResponse = (SurveyTextResponse) itemResponse;

        if (textResponse.getDefinitionId().equals(textDefinitionId))
        {
          return textResponse;
        }
      }
    }

    return null;
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
   * Set the date and time the survey response was received.
   *
   * @param responded the date and time the survey response was received
   */
  public void setResponded(Date responded)
  {
    this.responded = responded;
  }

  /**
   * Returns the String representation of the survey response.
   *
   * @return the String representation of the survey response
   */
  @Override
  public String toString()
  {
    return String.format("SurveyResponse {id=\"%s\", responded=\"%s\"}", getId(),
        DateUtil.getYYYYMMDDWithTimeFormat().format(getResponded()));
  }

  private void initItemResponses(List<SurveyItemDefinition> itemDefinitions)
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
          for (SurveyGroupMemberDefinition groupMemberDefinition :
              groupRatingsDefinition.getGroupMemberDefinitions())
          {
            itemResponses.add(new SurveyGroupRatingResponse(groupRatingsDefinition,
                groupRatingDefinition, groupMemberDefinition));
          }
        }
      }
      else if (itemDefinition instanceof SurveySectionDefinition)
      {
        SurveySectionDefinition sectionDefinition = (SurveySectionDefinition) itemDefinition;

        initItemResponses(sectionDefinition.getItemDefinitions());
      }
      else if (itemDefinition instanceof SurveyTextDefinition)
      {
        SurveyTextDefinition textDefinition = (SurveyTextDefinition) itemDefinition;

        itemResponses.add(new SurveyTextResponse(textDefinition));
      }
    }
  }
}
